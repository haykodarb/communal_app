import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/notifications_backend.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/notifications/notifications_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  String _notificationStart(CustomNotification notification) {
    switch (notification.type.table) {
      case 'loans':
        switch (notification.type.event) {
          case 'accepted':
            return 'Your request for ';
          case 'rejected':
            return 'Your request for ';
          case 'requested':
            return 'A request has been submitted for ';
        }
        break;
      case 'memberships':
        switch (notification.type.event) {
          case 'invited':
            return 'You have been invited to join the community ';
        }
        break;
      default:
        break;
    }

    return '';
  }

  String? _notificationEnd(CustomNotification notification) {
    switch (notification.type.table) {
      case 'loans':
        switch (notification.type.event) {
          case 'accepted':
            return ' has been accepted by ';
          case 'rejected':
            return ' has been rejected by ';
          case 'requested':
            return ' by ';
        }
        break;
      case 'memberships':
        switch (notification.type.event) {
          case 'invited':
            return null;
        }
        break;
      default:
        break;
    }

    return '';
  }

  IconData? _notificationIcon(NotificationType type) {
    switch (type.table) {
      case 'loans':
        return Atlas.account_arrows;
      case 'memberships':
        return Atlas.envelope_paper_email;
      default:
        return null;
    }
  }

  Widget _actionButton(CustomNotification notification) {
    switch (notification.type.table) {
      case 'loans':
        return IconButton(
          alignment: Alignment.centerRight,
          onPressed: () {
            Get.toNamed(
              RouteNames.loanInfoPage,
              arguments: {
                'loan_id': notification.resource_id,
              },
            );
          },
          icon: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 30,
            opticalSize: 30,
          ),
        );
      case 'memberships':
        return PopupMenuButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.more_vert,
            size: 30,
          ),
          onSelected: (value) {},
          itemBuilder: (context) {
            return <PopupMenuEntry>[
              const PopupMenuItem(
                value: 0,
                child: Text('Accept'),
              ),
              const PopupMenuItem(
                value: 1,
                child: Text('Reject'),
              ),
            ];
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _notificationCard(CustomNotification notification) {
    return Builder(
      builder: (context) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  _notificationIcon(notification.type),
                  size: 40,
                ),
                const VerticalDivider(),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                        height: 1.5,
                      ),
                      children: <TextSpan>[
                        TextSpan(text: _notificationStart(notification)),
                        TextSpan(
                          text: notification.resource_name,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(
                          text: _notificationEnd(notification),
                          recognizer: TapGestureRecognizer()..onTap = () {},
                        ),
                        TextSpan(
                          text: notification.sender?.username,
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 25),
                _actionButton(notification),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: NotificationsController(),
      builder: (NotificationsController controller) {
        return Scaffold(
          drawer: CommonDrawerWidget(),
          appBar: AppBar(
            title: Text('notifications'.tr),
          ),
          body: Center(
            child: Obx(
              () => ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: controller.notifications.length,
                itemBuilder: (context, index) {
                  final CustomNotification notification = controller.notifications[index];
                  return _notificationCard(notification);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
