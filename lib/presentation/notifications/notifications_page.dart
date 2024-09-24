import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/notifications_backend.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
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
          case 'created':
            return 'A request has been submitted for ';
          case 'returned':
            return 'Your loan for ';
        }
        break;
      case 'memberships':
        switch (notification.type.event) {
          case 'created':
            return 'You have been invited to join the community ';
          case 'accepted':
            return 'You have joined the community ';
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
          case 'created':
            return ' by ';
          case 'returned':
            return ' has been marked as returned by ';
        }
        break;
      case 'memberships':
        switch (notification.type.event) {
          case 'created':
            return null;
          case 'accepted':
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
        return const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 30,
          opticalSize: 30,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _notificationCard(
    NotificationsController controller,
    CustomNotification notification,
  ) {
    return Builder(
      builder: (context) {
        return Card(
          color: notification.seen
              ? null
              : Theme.of(context).colorScheme.secondary.withOpacity(0.15),
          child: InkWell(
            onTap: () {
              if (notification.membership != null) {
                Get.toNamed(
                  RouteNames.communitySpecificPage,
                  arguments: {'community': notification.membership!.community},
                );
              }

              if (notification.loan != null) {
                Get.toNamed(
                  RouteNames.loanInfoPage,
                  arguments: {
                    'loan_id': notification.loan!.id,
                  },
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: notification.seen
                              ? Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withOpacity(0.25)
                              : Theme.of(context).colorScheme.surfaceContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _notificationIcon(notification.type),
                          color: notification.seen
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.secondary,
                          size: 26,
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: notification.seen
                                  ? FontWeight.w400
                                  : FontWeight.w500,
                            ),
                            children: <TextSpan>[
                              TextSpan(text: _notificationStart(notification)),
                              TextSpan(
                                text: notification.loan?.book.title ??
                                    notification.membership?.community.name ??
                                    '',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              TextSpan(
                                text: _notificationEnd(notification),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {},
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              TextSpan(
                                text: notification.sender?.username,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const VerticalDivider(width: 25),
                      _actionButton(notification),
                    ],
                  ),
                  Visibility(
                    visible: notification.type.table == 'memberships' &&
                        notification.type.event == 'created',
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          const VerticalDivider(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => controller.respondToInvitation(
                                notification.membership!.id,
                                true,
                              ),
                              style: ElevatedButton.styleFrom(
                                fixedSize: const Size.fromHeight(40),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              child: const Text('Accept'),
                            ),
                          ),
                          const VerticalDivider(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => controller.respondToInvitation(
                                notification.membership!.id,
                                false,
                              ),
                              style: OutlinedButton.styleFrom(
                                fixedSize: const Size.fromHeight(40),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              child: const Text('Reject'),
                            ),
                          ),
                          const VerticalDivider(width: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
          body: Obx(
            () {
              return CommonLoadingBody(
                loading: controller.loading.value,
                child: Center(
                  child: Obx(
                    () => ListView.separated(
                      padding: const EdgeInsets.all(10),
                      itemCount: controller.notifications.length,
                      separatorBuilder: (BuildContext context, int int) =>
                          const Divider(height: 5),
                      itemBuilder: (context, index) {
                        if (controller.notifications.isEmpty) {
                          return const Center(
                            child: Text('No notifications'),
                          );
                        }

                        final CustomNotification notification =
                            controller.notifications[index];
                        return _notificationCard(controller, notification);
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
