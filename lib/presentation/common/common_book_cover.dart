import 'dart:typed_data';

import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonBookCoverController extends GetxController {
  CommonBookCoverController({
    required this.book,
  });

  final Book book;
  Uint8List? coverBytes;

  final RxBool loading = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    coverBytes = await BooksBackend.getBookCover(book);
    loading.value = false;
  }
}

class CommonBookCover extends StatelessWidget {
  const CommonBookCover(this.book, {super.key, this.radius, this.height = 960});

  final Book book;
  final double? radius;
  final int height;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: CommonBookCoverController(book: book),
        tag: book.image_path,
        builder: (controller) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius ?? 5),
            ),
            clipBehavior: Clip.hardEdge,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Obx(
                () {
                  if (controller.loading.value) {
                    return const CommonLoadingImage();
                  }

                  return Image.memory(controller.coverBytes!);
                },
              ),
            ),
          );
        });
  }
}
