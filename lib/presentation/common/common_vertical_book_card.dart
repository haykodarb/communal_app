import 'dart:math' as math;

import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CommonVerticalBookCard extends StatelessWidget {
  const CommonVerticalBookCard({
    super.key,
    required this.book,
    this.clickable = true,
    this.axis = Axis.vertical,
    this.note,
    this.showLoaned = false,
  });

  final Book book;

  /// Optional third line, e.g. "via <friend> · <location>".
  final String? note;

  /// My Books: marks loaned books with a ribbon across the cover's top-left
  /// corner.
  final bool showLoaned;
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
                    : RouteNames.foreignBooksPage
                        .replaceFirst(':bookId', book.id),
                extra: {
                  'ownerId': book.owner.id,
                },
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
          width: axis == Axis.vertical ? null : 200,
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Expanded(
                flex: axis == Axis.vertical ? 0 : 1,
                child: showLoaned && book.loaned
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Stack(
                          children: [
                            CommonBookCover(book),
                            const _LoanedRibbon(),
                          ],
                        ),
                      )
                    : CommonBookCover(book),
              ),
              const Divider(height: 10),
              Text(
                book.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 5),
              Text(
                book.author,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  height: 1.2,
                ),
              ),
              if (note != null && note!.isNotEmpty)
                Text(
                  note!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 10,
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A band rotated 45° about its centre, which sits 26px in from both edges
/// on the corner's diagonal (leaving ~73px of it showing, room for
/// "PRESTADO"); the cover's clip cuts its ends. In the loaned purple.
class _LoanedRibbon extends StatelessWidget {
  const _LoanedRibbon();

  static const double _width = 100;
  static const double _height = 16;
  static const double _inset = 26;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Positioned(
      top: _inset - _height / 2,
      left: _inset - _width / 2,
      child: IgnorePointer(
        child: Transform.rotate(
          angle: -math.pi / 4,
          child: Container(
            width: _width,
            height: _height,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.tertiary,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40000000),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              'Loaned'.tr.toUpperCase(),
              style: TextStyle(
                color: colors.onTertiary,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdjustableWidthText extends StatefulWidget {
  const AdjustableWidthText({
    super.key,
    required this.card,
    required this.imageKey,
  });

  final CommonVerticalBookCard card;
  final GlobalKey imageKey;

  @override
  State<AdjustableWidthText> createState() => _AdjustableWidthTextState();
}

class _AdjustableWidthTextState extends State<AdjustableWidthText> {
  double imageWidth = 200;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.card.axis == Axis.vertical ? null : 200,
      padding: const EdgeInsets.only(bottom: 5, left: 5, right: 5),
      child: Column(
        children: [
          Text(
            widget.card.book.title,
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
            widget.card.book.author,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
