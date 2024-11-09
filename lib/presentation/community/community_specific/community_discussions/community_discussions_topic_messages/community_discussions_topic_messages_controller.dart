import 'dart:async';
import 'package:communal/backend/discussions_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/discussion.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityDiscussionsTopicMessagesController extends GetxController {
  CommunityDiscussionsTopicMessagesController({required this.topicId});
  final String topicId;
  late DiscussionTopic topic;

  final RxList<DiscussionMessage> messages = <DiscussionMessage>[].obs;

  final TextEditingController textEditingController = TextEditingController();

  final RxBool loading = false.obs;
  final RxBool sending = false.obs;

  String typedMessage = '';

  StreamSubscription<RealtimeMessage>? subscription;

  @override
  Future<void> onInit() async {
    super.onInit();

    loading.value = true;
    final CommunityDiscussionsController communityDiscussionsController =
        Get.find();

    DiscussionTopic? tmp =
        communityDiscussionsController.topics.firstWhereOrNull(
      (element) => element.id == topicId,
    );

    if (tmp != null) {
      topic = tmp;
    } else {
      final BackendResponse response =
          await DiscussionsBackend.getDiscussionTopicById(topicId);

      if (response.success) {
        topic = response.payload;
      }
    }

    loadMessages();

    subscription ??=
        RealtimeBackend.streamController.stream.listen(_realtimeListener);

    loading.value = false;
  }

  @override
  Future<void> onClose() async {
    await subscription?.cancel();

    super.onClose();
  }

  Future<void> _realtimeListener(RealtimeMessage realtimeMessage) async {
    if (realtimeMessage.table != 'discussion_messages') return;

    if (realtimeMessage.eventType != PostgresChangeEvent.insert) return;

    if (realtimeMessage.new_row['sender'] == UsersBackend.currentUserId) return;

    if (realtimeMessage.new_row['topic'] != topicId) return;

    final DiscussionMessage? existingMessageForProfile =
        messages.firstWhereOrNull(
      (element) => element.sender.id == realtimeMessage.new_row['sender'],
    );

    DiscussionMessage? newMessage;

    if (existingMessageForProfile != null) {
      newMessage = DiscussionMessage(
        id: realtimeMessage.new_row['id'],
        created_at: DateTime.parse(
          realtimeMessage.new_row['created_at'],
        ),
        sender: existingMessageForProfile.sender,
        content: realtimeMessage.new_row['content'],
        topicId: realtimeMessage.new_row['topic'],
      );
    } else {
      final BackendResponse response =
          await DiscussionsBackend.getDiscussionMessageById(
        realtimeMessage.new_row['id'],
      );

      if (!response.success) return;

      newMessage = response.payload;
    }

    if (newMessage == null) return;
    messages.insert(0, newMessage);
  }

  Future<void> loadMessages() async {
    final BackendResponse response =
        await DiscussionsBackend.getDiscussionMessagesForTopic(topicId);

    if (response.success) {
      messages.value = response.payload;
    }
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

    final String randomID = UniqueKey().toString();

    final DiscussionMessage newMessage = DiscussionMessage(
      id: randomID,
      created_at: DateTime.now(),
      sender: Profile(
        id: UsersBackend.currentUserId,
        username: UsersBackend.getCurrentUsername(),
        show_email: false,
      ),
      content: typedMessage,
      topicId: topicId,
    );

    messages.insert(0, newMessage);

    final BackendResponse response =
        await DiscussionsBackend.insertDiscussionMessageInTopic(
      topicId,
      typedMessage,
    );

    if (response.success) {
      final int index =
          messages.indexWhere((element) => element.id == randomID);

      messages[index] = response.payload;
    } else {
      messages.removeWhere((element) => element.id == randomID);

      Get.dialog(
        CommonAlertDialog(
          title: 'Could not send message, error: ${response.payload}.',
        ),
      );
    }

    typedMessage = '';
    sending.value = false;
  }
}
