import 'dart:async';

import 'package:communal/backend/loans_backend.dart';
import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommonDrawerController extends GetxController {
  final RxInt messageNotifications = 0.obs;
  final RxInt loanNotifications = 0.obs;
  final RxInt invitationsNotifications = 0.obs;

  StreamSubscription? realtimeSubscription;

  void goToRoute(String routeName) {
    if (Get.currentRoute != routeName) {
      Get.offAllNamed(routeName);
    }
  }

  @override
  Future<void> onReady() async {
    super.onReady();

    loanNotifications.value = (await LoansBackend.getLoanCountWhere(LoansRequestType.userIsOwner)).payload;

    invitationsNotifications.value = (await UsersBackend.getInvitationsCountForUser()).payload;

    getUnreadChats();

    realtimeSubscription ??= RealtimeBackend.streamController.stream.listen(realtimeChangeHandler);
  }

  @override
  Future<void> onClose() async {
    await realtimeSubscription?.cancel();

    super.onClose();
  }

  Future<void> realtimeChangeHandler(RealtimeMessage realtimeMessage) async {
    switch (realtimeMessage.table) {
      case 'messages':
        if (realtimeMessage.eventType == PostgresChangeEvent.insert ||
            realtimeMessage.eventType == PostgresChangeEvent.update) {
          if (realtimeMessage.new_row['receiver'] == UsersBackend.currentUserId) {
            getUnreadChats();
          }
        }
        break;

      case 'memberships':
        if (realtimeMessage.eventType != PostgresChangeEvent.insert &&
            realtimeMessage.eventType != PostgresChangeEvent.update) return;

        if (realtimeMessage.new_row['member'] != UsersBackend.currentUserId) return;

        invitationsNotifications.value = (await UsersBackend.getInvitationsCountForUser()).payload;

        break;

      default:
        break;
    }
  }

  Future<void> getUnreadChats() async {
    final BackendResponse response = await MessagesBackend.getDistinctChats();

    if (response.success) {
      final List<Message> messages = response.payload;

      int unreadCount = 0;

      for (int i = 0; i < messages.length; i++) {
        if (!messages[i].is_read && messages[i].receiver.id == UsersBackend.currentUserId) {
          unreadCount++;
        }
      }

      messageNotifications.value = unreadCount;
    }
  }

  Future<void> getPendingLoans() async {
    loanNotifications.value = (await LoansBackend.getLoanCountWhere(LoansRequestType.userIsOwner)).payload;
  }

  Future<void> changeThemeMode() async {
    final ThemeMode newThemeMode = Get.isDarkMode ? ThemeMode.light : ThemeMode.dark;

    Get.changeThemeMode(newThemeMode);

    UserPreferences.setSelectedThemeMode(newThemeMode);
  }

  void handleLogout() {
    LoginBackend.logout();
    Get.offAllNamed(RouteNames.startPage);
  }
}
