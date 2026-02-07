import 'package:communal/models/custom_notification.dart';
import 'package:communal/presentation/notifications/notifications_controller.dart';
import 'package:communal/presentation/notifications/widgets/friendship_notification_widget.dart';
import 'package:communal/presentation/notifications/widgets/loan_notification_widget.dart';
import 'package:communal/presentation/notifications/widgets/membership_notification_widget.dart';
import 'package:flutter/material.dart';

class NotificationWidgetFactory {
  static Widget create({
    required CustomNotification notification,
    required NotificationsController controller,
    Key? key,
  }) {
    switch (notification.type.table) {
      case 'loans':
        return LoanNotificationWidget(
          key: key,
          notification: notification,
          controller: controller,
        );
      case 'friendships':
        return FriendshipNotificationWidget(
          key: key,
          notification: notification,
          controller: controller,
        );
      case 'memberships':
        return MembershipNotificationWidget(
          key: key,
          notification: notification,
          controller: controller,
        );
      default:
        return _buildUnknownNotification(notification, controller);
    }
  }

  static Widget _buildUnknownNotification(
    CustomNotification notification,
    NotificationsController controller,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.question_mark,
                color: Colors.grey,
                size: 26,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Unknown notification type: ${notification.type.table}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
