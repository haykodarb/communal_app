import 'dart:async';
import 'package:communal/backend/notifications_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/custom_notification.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsController extends GetxController {
  static const int pageSize = 20;

  final CommonListViewController<CustomNotification> listViewController =
      CommonListViewController<CustomNotification>(
    pageSize: pageSize,
  );

  StreamSubscription? streamSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();

    listViewController.registerNewPageCallback(loadNotifications);

    final Stream<RealtimeMessage> stream =
        RealtimeBackend.streamController.stream;

    streamSubscription = stream.listen(realtimeListener);
  }

  Future<void> realtimeListener(RealtimeMessage realtime) async {
    if (realtime.table != 'notifications') return;

    if (realtime.eventType == PostgresChangeEvent.delete) {
      if ((realtime.old_row?.isEmpty ?? true) ||
          realtime.old_row!['id'] == null) return;

      listViewController.itemList
          .removeWhere((element) => element.id == realtime.old_row!['id']);
      listViewController.itemList.refresh();
      listViewController.pageKey--;
    }

    if (realtime.new_row.isEmpty) return;
    if (realtime.new_row['receiver'] == null ||
        realtime.new_row['receiver'] != UsersBackend.currentUserId) return;

    final BackendResponse response =
        await NotificationsBackend.getNotificationById(
      realtime.new_row['id'],
    );

    if (response.success) {
      final CustomNotification new_notif = response.payload;

      int index_of_existing = listViewController.itemList.indexWhere(
        (element) => element.id == new_notif.id,
      );

      if (index_of_existing >= 0) {
        if (realtime.eventType == PostgresChangeEvent.update) {
          listViewController.itemList[index_of_existing] = new_notif;
        }

        if (realtime.eventType == PostgresChangeEvent.delete) {}
      } else {
        listViewController.itemList.insert(0, new_notif);
        listViewController.pageKey++;
      }

      listViewController.itemList.refresh();
    }
  }

  Future<List<CustomNotification>> loadNotifications(int pageKey) async {
    final BackendResponse response =
        await NotificationsBackend.getNotifications(pageKey, pageSize);

    if (response.success) {
      List<CustomNotification> new_notifs = response.payload;

      if (new_notifs.any((element) => !element.seen)) {
        NotificationsBackend.setNotificationsRead();
      }

      return new_notifs;
    }

    return [];
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
        listViewController.itemList.removeWhere(
          (element) => element.id == notification.id,
        );
      }

      listViewController.itemList.refresh();

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
