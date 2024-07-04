import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonVerticalBookCard extends StatelessWidget {
  const CommonVerticalBookCard({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await Get.toNamed(
          RouteNames.bookOwnedPage,
          arguments: {
            'book': book,
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(5),
          width: 180,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                clipBehavior: Clip.hardEdge,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: FutureBuilder(
                    future: BooksBackend.getBookCover(book),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CommonLoadingImage();
                      }

                      return Image.memory(
                        snapshot.data!,
                        gaplessPlayback: true,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ),
              const Divider(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
                child: Column(
                  children: [
                    Text(
                      book.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(height: 5),
                    Text(
                      book.author,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
