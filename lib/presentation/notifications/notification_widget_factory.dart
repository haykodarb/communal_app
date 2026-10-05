import 'package:communal/models/custom_notification.dart';
import 'package:communal/presentation/notifications/notifications_controller.dart';
import 'package:communal/presentation/notifications/widgets/friendship_notification_widget.dart';
import 'package:communal/presentation/notifications/widgets/loan_notification_widget.dart';
import 'package:communal/presentation/notifications/widgets/membership_notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationWidgetFactory {
  static Widget create({
    required CustomNotification notification,
    required NotificationsController controller,
    required int index,
    Key? key,
  }) {
    String? dateToShow;
    DateTime today = DateTime.now();
    CustomNotification? previousNotification;

    if (index > 0 && controller.listViewController.itemList.length > index) {
      previousNotification = controller.listViewController.itemList[index - 1];
    }

    if (!notification.seen) {
      if (previousNotification == null || previousNotification.seen) {
        dateToShow = 'New';
      }
    } else {
      int diffPrevious = 0;
      int yearsDiff = today.year - notification.updated_at.year;
      int diffToday = today.difference(notification.updated_at).inDays;

      if (previousNotification != null) {
        diffPrevious = notification.updated_at
            .difference(previousNotification.updated_at)
            .inDays;
      }

      if (previousNotification == null || diffPrevious != 0) {
        if (diffToday > 0) {
          dateToShow = DateFormat('dd MMM ${yearsDiff > 0 ? 'yyyy' : ''}',
                  Get.locale!.languageCode)
              .format(
                notification.updated_at.toLocal(),
              )
              .toString();
        } else {
          dateToShow = 'Today';
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Visibility(
          visible: dateToShow != null,
          child: Text(
            dateToShow ?? '',
            textAlign: TextAlign.left,
          ),
        ),
        Builder(builder: (context) {
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
        })
      ],
    );
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
