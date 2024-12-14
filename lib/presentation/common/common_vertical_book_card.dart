import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:flutter/material.dart';

class CommonVerticalBookCard extends StatelessWidget {
  const CommonVerticalBookCard({super.key, required this.book});

  final Book book;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(5),
        width: double.maxFinite,
        child: Column(
          children: [
            CommonBookCover(book),
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
    );
  }
}
