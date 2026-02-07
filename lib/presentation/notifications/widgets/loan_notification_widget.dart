import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/notifications/widgets/base_notification_widget.dart';
import 'package:flutter/material.dart';

class LoanNotificationWidget extends NotificationWidget {
  const LoanNotificationWidget({
    super.key,
    required super.notification,
    super.controller,
  });

  @override
  IconData get icon => Atlas.users_arrows;

  @override
  List<TextSpan> textSpans(BuildContext context) {
    final spans = <TextSpan>[];
    final bookTitle = notification.loan?.book.title ?? '';
    final senderName = notification.sender?.username ?? '';

    spans.add(TextSpan(text: notification.type.notificationStart));
    spans.add(TextSpan(
      text: bookTitle,
      style: highlightedButtonStyle(context),
    ));

    if (notification.type.notificationEnd != null) {
      spans.add(TextSpan(text: notification.type.notificationEnd));
    }

    spans.add(TextSpan(
      text: senderName,
      style: highlightedButtonStyle(context),
    ));

    return spans;
  }

  @override
  Widget? actionButtons(BuildContext context) => null;

  @override
  void onTap(BuildContext context) {
    notification.loan?.goToLoanInfoPage(context);
  }
}
