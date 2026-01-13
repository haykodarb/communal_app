import 'package:atlas_icons/atlas_icons.dart';
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
    };

    return iconMap[type.table];
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
              : Theme.of(context).colorScheme.secondary.withValues(alpha: 0.15),
          child: InkWell(
            onTap: () {
              if (notification.membership != null &&
                  notification.type.event == 'accepted') {
                context.push(
                  '${RouteNames.communityListPage}/${notification.membership!.community.id}',
                );
              }

              if (notification.loan != null) {
                context.push(
                  '${RouteNames.loansPage}/${notification.loan!.id}',
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Obx(
                () {
                  return CommonLoadingBody(
                    loading: notification.loading.value,
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
                                        .withValues(alpha: 0.25)
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
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
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: notification.seen
                                        ? FontWeight.w400
                                        : FontWeight.w500,
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: notification.type.notificationStart,
                                    ),
                                    TextSpan(
                                      text: notification.loan?.book.title ??
                                          notification
                                              .membership?.community.name ??
                                          '',
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    TextSpan(
                                      text: notification.type.notificationEnd,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {},
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        fontSize: 16,
                                        height: 1.5,
                                      ),
                                    ),
                                    TextSpan(
                                      text: notification.sender?.username,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
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
                                  child: CommonButton(
                                    onPressed: (BuildContext context) {
                                      controller.respondToInvitation(
                                        notification.membership!.id,
                                        notification,
                                        true,
                                        context,
                                      );
                                    },
                                    child: const Text('Accept'),
                                  ),
                                ),
                                const VerticalDivider(width: 10),
                                Expanded(
                                  child: CommonButton(
                                    type: CommonButtonType.outlined,
                                    onPressed: (BuildContext context) =>
                                        controller.respondToInvitation(
                                      notification.membership!.id,
                                      notification,
                                      false,
                                      context,
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
                  );
                },
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
          );
        });
  }
}
