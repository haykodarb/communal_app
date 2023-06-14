import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommonBookCard extends StatelessWidget {
  const CommonBookCard({
    super.key,
    required this.book,
    required this.textChildren,
    this.height = 200,
  });

  final Book book;
  final List<Text> textChildren;
  final double height;

  Widget _loadingBookIndicator() {
    return Center(
      child: SizedBox(
        height: 50,
        width: 50,
        child: LoadingAnimationWidget.threeArchedCircle(
          color: Get.theme.colorScheme.primary,
          size: 50,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        height: height,
        child: Obx(
          () {
            if (book.loading.value) {
              return _loadingBookIndicator();
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: SizedBox(
                    child: FutureBuilder(
                      future: BooksBackend.getBookCover(book),
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
                ),
                const VerticalDivider(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: textChildren.map(
                            (Text element) {
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