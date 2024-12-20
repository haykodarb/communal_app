import 'dart:async';
import 'package:communal/backend/notifications_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsController extends GetxController {
  final RxList<CustomNotification> notifications = <CustomNotification>[].obs;
  final RxBool loading = false.obs;

  StreamSubscription? streamSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();

    await loadNotifications();

    final Stream<RealtimeMessage> stream =
        RealtimeBackend.streamController.stream;

    streamSubscription = stream.listen(realtimeListener);
  }

  Future<void> realtimeListener(RealtimeMessage realtime) async {
    if (realtime.eventType != PostgresChangeEvent.insert ||
        realtime.eventType != PostgresChangeEvent.update) return;

    if (realtime.table != 'notifications') return;
    if (realtime.new_row.isEmpty) return;

    final BackendResponse response =
        await NotificationsBackend.getNotificationById(
      realtime.new_row['id'],
    );

    if (response.success) {
      final CustomNotification new_notif = response.payload;

      int index_of_existing = notifications.indexWhere(
        (element) => element.id == new_notif.id,
      );

      if (index_of_existing >= 0) {
        notifications[index_of_existing] = new_notif;
      } else {
        notifications.insert(0, new_notif);
      }

      notifications.refresh();
    }
  }

  Future<void> loadNotifications() async {
    loading.value = true;

    final BackendResponse response =
        await NotificationsBackend.getNotifications();

    if (response.success) {
      notifications.value = response.payload;
      notifications.refresh();

      NotificationsBackend.setNotificationsRead();
    }

    loading.value = false;
  }

  Future<void> respondToInvitation(
    String membershipId,
    CustomNotification notification,
    bool value,
    BuildContext context,
  ) async {
    final bool accept = await CommonConfirmationDialog(
      title: '${value ? 'Accept' : 'Reject'} this invitation?',
    ).open(context);

    if (!accept) return;
    notification.loading.value = true;

    final BackendResponse response = await UsersBackend.respondToInvitation(
      membershipId,
      value,
    );

    if (response.success) {
      if (value) {
        notification.type.event = 'accepted';
      } else {
        notifications.removeWhere((element) => element.id == notification.id);
      }

      notifications.refresh();

      notification.loading.value = false;
    } else {
      notification.loading.value = false;
      if (!context.mounted) return;

      const CommonAlertDialog(
        title: 'Could not accept invitation, server error.',
      ).open(context);
    }
  }
}
