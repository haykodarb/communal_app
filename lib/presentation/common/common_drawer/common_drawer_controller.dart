import 'dart:async';

import 'package:communal/backend/loans_backend.dart';
import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/membership.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/message.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommonDrawerController extends GetxController {
  final RxInt messageNotifications = 0.obs;
  final RxInt loanNotifications = 0.obs;
  final RxInt invitationsNotifications = 0.obs;

  RealtimeChannel? loansSubscription;
  RealtimeChannel? messagesSubscription;
  RealtimeChannel? invitationsSubscription;

  StreamController<Message> messagesStreamController = StreamController<Message>.broadcast();

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

    loansSubscription ??= LoansBackend.subscribeToLoanChanges(loanChangeHandler);
    loansSubscription?.subscribe();

    invitationsSubscription ??= UsersBackend.subscribeToMemberships(membershipChangeHandler);
    invitationsSubscription?.subscribe();

    messagesSubscription ??= MessagesBackend.subscribeToMessages(messageChangeHandler);
    messagesSubscription?.subscribe();
  }

  @override
  Future<void> onClose() async {
    await loansSubscription?.unsubscribe();
    await invitationsSubscription?.unsubscribe();
    await messagesSubscription?.unsubscribe();

    super.onClose();
  }

  Future<void> messageChangeHandler(Message message) async {
    messagesStreamController.add(message);

    if (message.receiver.id == UsersBackend.getCurrentUserId()) {
      getUnreadChats();
    }
  }

  Future<void> loanChangeHandler(Loan? loan) async {
    if (loan == null) {
      loanNotifications.value--;
      return;
    }

    if (loan.book.owner.id == UsersBackend.getCurrentUserId()) {
      loanNotifications.value = (await LoansBackend.getLoanCountWhere(LoansRequestType.userIsOwner)).payload;
    }
  }

  Future<void> membershipChangeHandler(Membership? membership) async {
    if (membership == null) {
      invitationsNotifications.value = (await UsersBackend.getInvitationsCountForUser()).payload;
      return;
    }

    if (membership.member.id == UsersBackend.getCurrentUserId()) {
      invitationsNotifications.value = (await UsersBackend.getInvitationsCountForUser()).payload;
    }
  }

  Future<void> getUnreadChats() async {
    final BackendResponse response = await MessagesBackend.getDistinctChats();

    if (response.success) {
      final List<Message> messages = response.payload;

      int unreadCount = 0;

      for (int i = 0; i < messages.length; i++) {
        if (!messages[i].is_read && messages[i].receiver.id == UsersBackend.getCurrentUserId()) {
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
