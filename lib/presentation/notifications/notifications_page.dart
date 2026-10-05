import 'package:communal/models/custom_notification.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/notifications/notification_widget_factory.dart';
import 'package:communal/presentation/notifications/notifications_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

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
              childBuilder: (notification, index) {
                return NotificationWidgetFactory.create(
                  notification: notification,
                  controller: controller,
                  index: index,
                );
              },
              controller: controller.listViewController,
            ),
          ),
        );
      },
    );
  }
}
