import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:flutter/material.dart';

class CommonBookCover extends StatelessWidget {
  const CommonBookCover(this.book, {super.key, this.radius, this.height = 960});

  final Book book;
  final double? radius;
  final int height;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 5),
      ),
      clipBehavior: Clip.hardEdge,
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: FutureBuilder(
          future: BooksBackend.getBookCover(book, height: height),
          builder: (context, snapshot) {
            final bool hasData = snapshot.hasData && snapshot.data != null;

            return AnimatedOpacity(
              opacity: hasData ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: Builder(
                builder: (context) {
                  if (!hasData) {
                    return const CommonLoadingImage();
                  } else {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                    );
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
