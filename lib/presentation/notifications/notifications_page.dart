import 'package:atlas_icons/atlas_icons.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:communal/models/custom_notification.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/notifications/notifications_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  IconData? _notificationIcon(NotificationType type) {
    final iconMap = {
      'loans': Atlas.account_arrows,
      'memberships': Atlas.envelope_paper_email,
      'friendships': Atlas.user_plus,
    };

    return iconMap[type.table];
  }

  Widget _notificationCard(
    NotificationsController controller,
    CustomNotification notification,
  ) {
    return Builder(
      builder: (context) {
        return Card(
          child: InkWell(
            onTap: () {
              if (notification.friendship != null &&
                  notification.type.event == 'accepted') {
                notification.friendship?.otherUser.goToProfilePage(context);
              }

              if (notification.loan != null) {
                context.push(
                  '${RouteNames.loansPage}/${notification.loan!.id}',
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Obx(
                () {
                  return CommonLoadingBody(
                    loading: notification.loading.value,
                    child: Row(
                      children: [
                        _notificationData(notification, context),
                        _notificationButtons(notification, controller),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _notificationButtons(
    CustomNotification notification,
    NotificationsController controller,
  ) {
    return Visibility(
      visible: notification.type.table == 'friendships' &&
          notification.type.event == 'created',
      child: Flexible(
        flex: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CommonButton(
              onPressed: (BuildContext context) {
                controller.respondToFriendshipRequest(
                  notification.friendship!.id,
                  notification,
                  true,
                  context,
                );
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
              onPressed: (BuildContext context) =>
                  controller.respondToFriendshipRequest(
                notification.friendship!.id,
                notification,
                false,
                context,
              ),
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
      ),
    );
  }

  Expanded _notificationData(
    CustomNotification notification,
    BuildContext context,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _notificationIcon(notification.type),
              color: Theme.of(context).colorScheme.secondary,
              size: 26,
            ),
          ),
          const VerticalDivider(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w400,
                  height: 1.25,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: notification.type.notificationStart,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                  TextSpan(
                    text: notification.loan?.book.title ??
                        notification.sender?.username ??
                        '',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                  TextSpan(
                    text: notification.type.notificationEnd,
                    recognizer: TapGestureRecognizer()..onTap = () {},
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                  TextSpan(
                    text: notification.type.table == 'friendships'
                        ? null
                        : notification.sender?.username,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: NotificationsController(),
      builder: (NotificationsController controller) {
        return SafeArea(
          child: Scaffold(
            drawer: Responsive.isMobile(context)
                ? const CommonDrawerWidget()
                : null,
            appBar: Responsive.isMobile(context)
                ? AppBar(title: Text('Notifications'.tr))
                : null,
            body: CommonListView<CustomNotification>(
              noItemsText: 'No notifications.',
              childBuilder: (notification) {
                return _notificationCard(controller, notification);
              },
              controller: controller.listViewController,
            ),
          ),
        );
      },
    );
  }
}
