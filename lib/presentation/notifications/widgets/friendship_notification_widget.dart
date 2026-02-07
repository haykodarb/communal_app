import 'package:atlas_icons/atlas_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/notifications/widgets/base_notification_widget.dart';
import 'package:flutter/material.dart';

class FriendshipNotificationWidget extends NotificationWidget {
  const FriendshipNotificationWidget({
    super.key,
    required super.notification,
    super.controller,
  });

  @override
  IconData get icon => Atlas.user_plus;

  @override
  List<TextSpan> textSpans(BuildContext context) {
    final spans = <TextSpan>[];
    final senderName = notification.sender?.username ?? '';

    if (notification.type.event == 'created') {
      spans.add(TextSpan(
        text: senderName,
        style: highlightedButtonStyle(context),
      ));
      spans.add(TextSpan(text: notification.type.notificationEnd));
    } else {
      spans.add(TextSpan(text: notification.type.notificationStart));
      spans.add(
        TextSpan(
          text: senderName,
          style: highlightedButtonStyle(context),
        ),
      );
    }

    return spans;
  }

  @override
  Widget? actionButtons(BuildContext context) {
    if (notification.type.event != 'created') {
      return null;
    }

    return Flexible(
      flex: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CommonButton(
            onPressed: (BuildContext context) {
              if (notification.friendship != null && controller != null) {
                controller!.respondToFriendshipRequest(
                  notification.friendship!.id,
                  notification,
                  true,
                  context,
                );
              }
            },
            expand: false,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.zero,
              fixedSize: const Size(70, 30),
            ),
            child: const AutoSizeText(
              'Accept',
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const VerticalDivider(width: 5),
          CommonButton(
            type: CommonButtonType.tonal,
            expand: false,
            onPressed: (BuildContext context) {
              if (notification.friendship != null && controller != null) {
                controller!.respondToFriendshipRequest(
                  notification.friendship!.id,
                  notification,
                  false,
                  context,
                );
              }
            },
            style: FilledButton.styleFrom(
              fixedSize: const Size(70, 30),
              padding: EdgeInsets.zero,
            ),
            child: const AutoSizeText(
              'Reject',
              maxLines: 1,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onTap(BuildContext context) {
    if (notification.friendship != null &&
        notification.type.event == 'accepted') {
      notification.friendship?.otherUser.goToProfilePage(context);
    }
  }
}
