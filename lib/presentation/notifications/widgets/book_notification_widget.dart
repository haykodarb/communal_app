import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/notifications/widgets/base_notification_widget.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// books/available: a book you waitlisted has been returned.
class BookNotificationWidget extends NotificationWidget {
  const BookNotificationWidget({
    super.key,
    required super.notification,
    super.controller,
  });

  @override
  IconData get icon => Atlas.library;

  @override
  List<TextSpan> textSpans(BuildContext context) {
    return [
      TextSpan(
        text: notification.book?.title ?? '',
        style: highlightedButtonStyle(context),
      ),
      TextSpan(text: notification.type.notificationEnd ?? ''),
    ];
  }

  @override
  Widget? actionButtons(BuildContext context) => null;

  @override
  void onTap(BuildContext context) {
    final String? bookId = notification.book?.id;
    if (bookId == null) return;
    context.push(RouteNames.foreignBooksPage.replaceFirst(':bookId', bookId));
  }
}
