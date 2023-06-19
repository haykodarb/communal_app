import 'dart:async';
import 'package:communal/backend/discussions_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/discussion.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityDiscussionsTopicMessagesController extends GetxController {
  final RxList<DiscussionMessage> messages = <DiscussionMessage>[].obs;

  final DiscussionTopic topic = Get.arguments['topic'];

  final TextEditingController textEditingController = TextEditingController();

  final RxBool loading = false.obs;

  final RxBool sending = false.obs;

  String typedMessage = '';

  RealtimeChannel? subscription;

  @override
  void onInit() {
    super.onInit();

    loadMessages();

    subscription ??= DiscussionsBackend.subscribeToTopicMessages(addMessage, topic);

    subscription?.subscribe();
  }

  @override
  void onClose() {
    subscription?.unsubscribe();

    super.onClose();
  }

  void addMessage(DiscussionMessage message) {
    messages.insert(0, message);
  }

  Future<void> loadMessages() async {
    loading.value = true;
    final BackendResponse response = await DiscussionsBackend.getDiscussionMessagesForTopic(topic);

    if (response.success) {
      messages.value = response.payload;
    }

    loading.value = false;
  }

  void onTypedMessageChanged(String? value) {
    if (value != null) {
      typedMessage = value;
    }
  }

  Future<void> onMessageSubmit() async {
    if (typedMessage.isEmpty) return;

    sending.value = true;

    textEditingController.clear();

    final BackendResponse response = await DiscussionsBackend.insertDiscussionMessageInTopic(topic, typedMessage);

    if (response.success) {
      addMessage(response.payload);
    }

    typedMessage = '';
    sending.value = false;
  }
}
