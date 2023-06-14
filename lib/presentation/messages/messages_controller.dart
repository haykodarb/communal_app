import 'dart:async';

import 'package:communal/backend/messages_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesController extends GetxController {
  final RxList<Message> distinctChats = <Message>[].obs;

  final RxBool loading = false.obs;

  StreamController<Message> streamController = StreamController<Message>.broadcast();

  RealtimeChannel? subscription;

  @override
  void onInit() {
    super.onInit();

    subscription ??= MessagesBackend.subscribeToMessages(newMessageReceived);

    subscription?.subscribe();

    loadChats();
  }

  @override
  void onClose() {
    subscription?.unsubscribe();
    super.onClose();
  }

  Future<void> newMessageReceived(Message message) async {
    streamController.add(message);

    if (distinctChats.any((element) => element.id == message.id)) {
      distinctChats.firstWhereOrNull((element) => element.id == message.id)?.is_read = true;
      distinctChats.refresh();
      return;
    }

    final BackendResponse response = await MessagesBackend.getMessageWithId(message.id);

    if (!response.success) return;

    final Message newMessage = response.payload;

    final int indexOfExisting = distinctChats.indexWhere(
      (element) =>
          (element.receiver.id == newMessage.receiver.id && element.sender.id == newMessage.sender.id) ||
          (element.sender.id == newMessage.receiver.id && element.receiver.id == newMessage.sender.id),
    );

    if (indexOfExisting >= 0) {
      distinctChats[indexOfExisting] = newMessage;
    } else {
      distinctChats.insert(0, newMessage);
    }

    distinctChats.refresh();
  }

  Future<void> goToSpecificChat(Profile chatter) async {
    Get.toNamed(
      RouteNames.messagesSpecificPage,
      arguments: {
        'user': chatter,
        'stream': streamController.stream,
      },
    );
  }

  Future<void> loadChats() async {
    loading.value = true;

    final BackendResponse response = await MessagesBackend.getDistinctChats();

    if (response.success) {
      distinctChats.value = response.payload;
    }

    loading.value = false;
  }
}
