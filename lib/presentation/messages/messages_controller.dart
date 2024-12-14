import 'dart:async';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesController extends GetxController {
  static const int pageSize = 20;

  final CommonListViewController<Rx<Message>> listViewController = CommonListViewController(pageSize: pageSize);

  RealtimeChannel? subscription;

  StreamSubscription? streamSubscription;

  @override
  void onReady() {
    super.onReady();

    listViewController.registerNewPageCallback(loadChats);

    final Stream<RealtimeMessage> stream = RealtimeBackend.streamController.stream;

    streamSubscription = stream.listen(_realtimeListener);
  }

  @override
  Future<void> onClose() async {
    await streamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _realtimeListener(RealtimeMessage realtimeMessage) async {
    if (realtimeMessage.table != 'messages') return;

    if (realtimeMessage.eventType != PostgresChangeEvent.insert &&
        realtimeMessage.eventType != PostgresChangeEvent.update) return;

    final Message unfetchedMessage = Message(
      id: realtimeMessage.new_row['id'],
      created_at: DateTime.parse(realtimeMessage.new_row['created_at']),
      sender: Profile(id: realtimeMessage.new_row['sender'], username: '', show_email: false),
      receiver: Profile(id: realtimeMessage.new_row['receiver'], username: '', show_email: false),
      content: realtimeMessage.new_row['content'],
      is_read: realtimeMessage.new_row['is_read'],
    );

    final BackendResponse response = await MessagesBackend.getChatWithId(unfetchedMessage.id);

    if (!response.success) return;

    final Message message = response.payload;

    final int indexOfExistingMessage = listViewController.itemList.indexWhere(
      (element) => element.value.id == message.id,
    );

    if (indexOfExistingMessage >= 0) {
      listViewController.itemList[indexOfExistingMessage] = message.obs;
      listViewController.itemList.refresh();
      return;
    }

    final int indexOfExistingChat = listViewController.itemList.indexWhere(
      (element) =>
          (element.value.receiver.id == message.receiver.id && element.value.sender.id == message.sender.id) ||
          (element.value.sender.id == message.receiver.id && element.value.receiver.id == message.sender.id),
    );

    if (indexOfExistingChat >= 0) {
      listViewController.itemList[indexOfExistingChat].value = message;
    } else {
      listViewController.itemList.insert(0, message.obs);
      listViewController.pageKey++;
    }

    listViewController.itemList.refresh();
  }

  Future<void> goToSpecificChat(Profile chatter, BuildContext context) async {
    context.push('${RouteNames.messagesPage}/${chatter.id}');
  }

  Future<void> deleteChatsWithUsers(
    Profile chatter,
    BuildContext context,
  ) async {
    final bool deleteConfirm = await const CommonConfirmationDialog(
      title: 'Delete chat?',
    ).open(context);

    if (deleteConfirm) {
      final BackendResponse response = await MessagesBackend.deleteMessagesWithUser(chatter);

      if (response.success) {
        listViewController.itemList.removeWhere(
          (element) => element.value.sender.id == chatter.id || element.value.receiver.id == chatter.id,
        );
        listViewController.pageKey--;
        listViewController.itemList.refresh();
      }
    }
  }

  Future<List<Rx<Message>>> loadChats(int pageKey) async {
    final BackendResponse<List<Message>> response = await MessagesBackend.getDistinctChats();

    if (response.success) {
      return response.payload.map((e) => e.obs).toList();
    }

    return [];
  }
}
