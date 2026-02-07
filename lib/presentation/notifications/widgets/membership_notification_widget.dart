import 'package:atlas_icons/atlas_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/notifications/widgets/base_notification_widget.dart';
import 'package:flutter/material.dart';

class MembershipNotificationWidget extends NotificationWidget {
  const MembershipNotificationWidget({
    super.key,
    required super.notification,
    super.controller,
  });

  @override
  IconData get icon => Atlas.envelope_paper_email;

  @override
  List<TextSpan> textSpans(BuildContext context) {
    final spans = <TextSpan>[];
    final String communityName = notification.membership?.community.name ?? '';
    final String senderName = notification.sender?.username ?? '';

    // Basic implementation - can be extended based on membership event types
    if (notification.type.event == 'created') {
      spans.add(const TextSpan(text: 'You have been invited to join '));
      spans.add(
        TextSpan(
          text: communityName,
          style: highlightedButtonStyle(context),
        ),
      );
      spans.add(const TextSpan(text: ' by '));
      spans.add(
        TextSpan(
          text: senderName,
          style: highlightedButtonStyle(context),
        ),
      );
    }

    if (notification.type.event == 'accepted') {
      spans.add(const TextSpan(text: 'You have joined community '));
      spans.add(
        TextSpan(
          text: communityName,
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
    if (notification.type.event == 'accepted') {
      notification.membership?.community.goToCommunityPage(context);
    }
  }
}
