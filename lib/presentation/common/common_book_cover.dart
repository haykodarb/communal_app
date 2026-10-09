import 'dart:typed_data';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonBookCoverController extends GetxController {
  CommonBookCoverController({
    required this.book,
  }) {
    // A cover seen before shows on the first frame: grid cells are disposed
    // when they scroll away, and reading the disk cache again would flash
    // the placeholder every time one scrolls back in.
    final Uint8List? cached = _memoryCache[book.image_path];
    if (cached != null) {
      coverBytes = cached;
      loading.value = false;
    }
  }

  /// Covers already loaded this session, by image path. The same bytes
  /// instance also lets Image.memory reuse its decoded image.
  static final Map<String, Uint8List> _memoryCache = {};

  final Book book;
  Uint8List coverBytes = Uint8List(0);

  final RxBool loading = true.obs;

  @override
  Future<void> onReady() async {
    super.onReady();

    if (!loading.value) return;

    coverBytes = await BooksBackend.getBookCover(book);

    if (coverBytes.isNotEmpty) {
      _memoryCache[book.image_path] = coverBytes;
      loading.value = false;
    }
  }
}

class CommonBookCover extends StatelessWidget {
  const CommonBookCover(
    this.book, {
    super.key,
    this.radius,
    this.expandOnTap = false,
    this.expandOnLongPress = false,
  });

  final Book book;
  final double? radius;
  final bool expandOnTap;
  final bool expandOnLongPress;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      // GetBuilder only reads init/tag when it first mounts, so when a list
      // reuses this element for another book (e.g. one inserted above it),
      // the key makes it start over instead of keeping the old cover.
      key: ValueKey(book.image_path),
      init: CommonBookCoverController(book: book),
      tag: book.image_path,
      builder: (controller) {
        return InkWell(
          enableFeedback: false,
          onLongPress: expandOnLongPress
              ? () => _buildDialog(context, controller)
              : null,
          onTap: expandOnTap ? () => _buildDialog(context, controller) : null,
          child: _imageWidget(controller),
        );
      },
    );
  }

  Hero _imageWidget(CommonBookCoverController controller) {
    return Hero(
      tag: book.image_path,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius ?? 5),
        ),
        padding: EdgeInsets.zero,
        clipBehavior: Clip.hardEdge,
        child: AspectRatio(
          aspectRatio: 3 / 4,
          child: Obx(
            () {
              if (controller.loading.value) {
                return const CommonLoadingImage();
              }

              return Image.memory(
                controller.coverBytes,
                gaplessPlayback: true,
              );
            },
          ),
        ),
      ),
    );
  }

  Future<dynamic> _buildDialog(
    BuildContext context,
    CommonBookCoverController controller,
  ) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      animationStyle: const AnimationStyle(
        curve: Curves.easeInOut,
        duration: Duration(milliseconds: 300),
        reverseCurve: Curves.easeInOut,
        reverseDuration: Duration(milliseconds: 300),
      ),
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          clipBehavior: Clip.hardEdge,
          child: _imageWidget(controller),
        );
      },
    );
  }
}
