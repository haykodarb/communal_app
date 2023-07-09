import 'dart:async';

import 'package:communal/backend/loans_backend.dart';
import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';

class CommonDrawerController extends GetxController {
  final RxInt messageNotifications = 0.obs;
  final RxInt loanNotifications = 0.obs;
  final RxInt invitationsNotifications = 0.obs;

  StreamSubscription? realtimeSubscription;

  final String username = UsersBackend.getCurrentUsername();

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
        if (realtimeMessage.eventType == 'INSERT' || realtimeMessage.eventType == 'UPDATE') {
          if (realtimeMessage.new_row['receiver'] == UsersBackend.currentUserId) {
            getUnreadChats();
          }
        }
        break;

      case 'loans':
        if (realtimeMessage.eventType == 'INSERT') {
          loanNotifications.value = (await LoansBackend.getLoanCountWhere(LoansRequestType.userIsOwner)).payload;
        }

        if (realtimeMessage.eventType == 'UPDATE' && realtimeMessage.new_row['loanee'] == UsersBackend.currentUserId) {
          loanNotifications.value = (await LoansBackend.getLoanCountWhere(LoansRequestType.userIsOwner)).payload;
        }
        break;
      case 'memberships':
        if (realtimeMessage.eventType != 'INSERT' && realtimeMessage.eventType != 'UPDATE') return;

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

  void handleLogout() {
    LoginBackend.logout();
    Get.offAllNamed(RouteNames.startPage);
  }
}
