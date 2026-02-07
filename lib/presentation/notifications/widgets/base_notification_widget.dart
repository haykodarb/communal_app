import 'package:communal/models/custom_notification.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/notifications/notifications_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class NotificationWidget extends StatelessWidget {
  final CustomNotification notification;
  final NotificationsController? controller;

  const NotificationWidget({
    super.key,
    required this.notification,
    this.controller,
  });

  IconData get icon;
  List<TextSpan> textSpans(BuildContext context);
  Widget? actionButtons(BuildContext context);
  void onTap(BuildContext context);

  TextStyle highlightedButtonStyle(BuildContext context) {
    return TextStyle(
      color: Theme.of(context).colorScheme.secondary,
      fontWeight: FontWeight.w500,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap(context),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Obx(
            () {
              return CommonLoadingBody(
                loading: notification.loading.value,
                child: Row(
                  children: [
                    _buildIcon(context),
                    const VerticalDivider(width: 10),
                    _buildText(context),
                    if (actionButtons(context) != null) actionButtons(context)!,
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.secondary,
        size: 26,
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    return Expanded(
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w400,
            height: 1.25,
          ),
          children: textSpans(context),
        ),
      ),
    );
  }
}
