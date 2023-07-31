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
    this.elevation,
  });

  final Book book;
  final List<Text> textChildren;
  final double height;
  final double? elevation;

  Widget _loadingBookIndicator() {
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
            if (book.loading.value) {
              return _loadingBookIndicator();
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: FutureBuilder(
                    future: BooksBackend.getBookCover(book),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CommonLoadingImage();
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Theme.of(context).colorScheme.surface,
                                ],
                                begin: const Alignment(0.75, 0),
                                end: const Alignment(1, 0),
                                stops: const [0, 1],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const VerticalDivider(width: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
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
