import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonVerticalBookCard extends StatelessWidget {
  const CommonVerticalBookCard({
    super.key,
    required this.book,
    this.clickable = true,
    this.axis = Axis.vertical,
  });

  final Book book;
  final bool clickable;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: clickable
          ? () {
              context.push(
                book.owner.isCurrentUser
                    ? '${RouteNames.myBooks}/${book.id}'
                    : RouteNames.foreignBooksPage.replaceFirst(':bookId', book.id),
              );
            }
          : null,
      hoverColor: Colors.transparent,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(5),
          child: Column(
            children: [
              Expanded(
                flex: axis == Axis.vertical ? 0 : 1,
                child: CommonBookCover(book),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(height: 5),
                    Text(
                      book.author,
                      textAlign: TextAlign.center,
                      maxLines: 1,
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
