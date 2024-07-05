import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/tools_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/tool.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonItemCard extends StatelessWidget {
  const CommonItemCard({
    super.key,
    required this.children,
    this.book,
    this.tool,
    this.height = 225,
    this.elevation,
  });

  final Book? book;
  final Tool? tool;
  final List<Widget> children;
  final double height;
  final double? elevation;

  Widget _loadingIndicator() {
    return Builder(
      builder: (context) {
        return Center(
          child: SizedBox(
            height: 50,
            width: 50,
            child: LoadingAnimationWidget.threeArchedCircle(
              color: Theme.of(context).colorScheme.primary,
              size: 50,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: elevation,
      child: SizedBox(
        height: height,
        child: Obx(
          () {
            if (book != null && book!.loading.value) {
              return _loadingIndicator();
            }

            if (tool != null && tool!.loading.value) {
              return _loadingIndicator();
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: FutureBuilder(
                    future: book == null ? ToolsBackend.getToolImage(tool!) : BooksBackend.getBookCover(book!),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CommonLoadingImage();
                      }

                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, right: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book == null ? tool!.name : book!.title,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: children.map(
                            (Widget element) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  element,
                                ],
                              );
                            },
                          ).toList(),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
