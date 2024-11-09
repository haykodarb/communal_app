import 'dart:async';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesController extends GetxController {
  final RxList<Rx<Message>> distinctChats = <Rx<Message>>[].obs;

  final RxBool loading = false.obs;

  RealtimeChannel? subscription;

  StreamSubscription? streamSubscription;

  @override
  void onReady() {
    super.onReady();

    final Stream<RealtimeMessage> stream =
        RealtimeBackend.streamController.stream;

    streamSubscription = stream.listen(_realtimeListener);

    loadChats();
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
      sender: Profile(
          id: realtimeMessage.new_row['sender'],
          username: '',
          show_email: false),
      receiver: Profile(
          id: realtimeMessage.new_row['receiver'],
          username: '',
          show_email: false),
      content: realtimeMessage.new_row['content'],
      is_read: realtimeMessage.new_row['is_read'],
    );

    final BackendResponse response =
        await MessagesBackend.getChatWithId(unfetchedMessage.id);

    if (!response.success) return;

    final Message message = response.payload;

    final int indexOfExistingMessage =
        distinctChats.indexWhere((element) => element.value.id == message.id);

    if (indexOfExistingMessage >= 0) {
      distinctChats[indexOfExistingMessage] = message.obs;
      return;
    }

    final int indexOfExistingChat = distinctChats.indexWhere(
      (element) =>
          (element.value.receiver.id == message.receiver.id &&
              element.value.sender.id == message.sender.id) ||
          (element.value.sender.id == message.receiver.id &&
              element.value.receiver.id == message.sender.id),
    );

    if (indexOfExistingChat >= 0) {
      distinctChats[indexOfExistingChat].value = message;
    } else {
      distinctChats.insert(0, message.obs);
    }
  }

  Future<void> goToSpecificChat(Profile chatter, BuildContext context) async {
    context.go('${RouteNames.messagesPage}/${chatter.id}', extra: chatter);
  }

  Future<void> deleteChatsWithUsers(Profile chatter) async {
    final bool deleteConfirm = await Get.dialog<bool>(
          CommonConfirmationDialog(
            title: 'Delete chat?',
            confirmCallback: () => Get.back<bool>(result: true),
            cancelCallback: () => Get.back<bool>(result: false),
          ),
        ) ??
        false;

    if (deleteConfirm) {
      final BackendResponse response =
          await MessagesBackend.deleteMessagesWithUser(chatter);

      if (response.success) {
        distinctChats.removeWhere((element) =>
            element.value.sender.id == chatter.id ||
            element.value.receiver.id == chatter.id);
      }
    }
  }

  Future<void> loadChats() async {
    loading.value = true;

    final BackendResponse<List<Message>> response =
        await MessagesBackend.getDistinctChats();

    if (response.success) {
      distinctChats.value = response.payload.map((e) => e.obs).toList();
    }

    loading.value = false;
  }
}
