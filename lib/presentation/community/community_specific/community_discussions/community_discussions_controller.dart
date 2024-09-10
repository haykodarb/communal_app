import 'dart:async';

import 'package:communal/backend/discussions_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/discussion.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityDiscussionsController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();

  final Community community = Get.arguments['community'];

  final RxList<DiscussionTopic> topics = <DiscussionTopic>[].obs;

  final RxBool firstLoad = false.obs;
  final RxBool loadingMore = false.obs;

  final RxString errorMessage = ''.obs;

  final FocusNode focusScope = FocusNode();

  Timer? searchDebounceTimer;
  Timer? loadMoreDebounceTimer;

  StreamSubscription<RealtimeMessage>? _subscription;

  @override
  void onInit() {
    super.onInit();
    getDiscussionTopics();

    _subscription ??=
        RealtimeBackend.streamController.stream.listen(streamListener);

  }

  @override
  Future<void> onClose() async {
    await _subscription?.cancel();

    super.onClose();

  }

  Future<void> streamListener(RealtimeMessage realtimeMessage) async {
    if (realtimeMessage.table != 'discussion_topics') return;

    Map<String, dynamic> messageMap = realtimeMessage.new_row;

    switch (realtimeMessage.eventType) {
      case PostgresChangeEvent.update:
        int indexOfTopic = topics.indexWhere(
          (element) => element.id == messageMap['id'],
        );

        if (indexOfTopic < 0) return;

        BackendResponse response =
            await DiscussionsBackend.getDiscussionMessageById(
          messageMap['last_message'],
        );

        if (response.success) {
          DiscussionMessage newMessage = response.payload;

          topics[indexOfTopic].last_message = newMessage;
          topics.refresh();
        }

        break;
      case PostgresChangeEvent.insert:
        int indexOfTopic = topics.indexWhere(
          (element) => element.id == messageMap['id'],
        );

        if (indexOfTopic >= 0) return;
        final BackendResponse response =
            await DiscussionsBackend.getDiscussionTopicById(
          messageMap['id'],
        );

        if (response.success) {
          final DiscussionTopic newTopic = response.payload;
          topics.add(newTopic);
        }

        break;
      default:
        break;
    }
  }

  Future<void> getDiscussionTopics() async {
    firstLoad.value = true;

    final BackendResponse response =
        await DiscussionsBackend.getDiscussionTopicsForCommunity(community);

    if (response.success) {
      topics.value = response.payload;
    }

    firstLoad.value = false;
  }

  void updateTopicMessage(DiscussionMessage message) {
    final int indexOfTopic =
        topics.indexWhere((element) => element.id == message.topicId);
    if (indexOfTopic >= 0) {
      topics[indexOfTopic].last_message = message;
    }

    topics.refresh();
  }

  Future<void> goToTopicMessages(DiscussionTopic topic) async {
    Get.toNamed(
      RouteNames.communityDiscussionsTopicMessages,
      arguments: {
        'topic': topic,
        'controller': this,
      },
    );
  }

  Future<void> goToDiscussionsTopicCreate() async {
    final DiscussionTopic? topic = await Get.toNamed<dynamic>(
      RouteNames.communityDiscussionsTopicCreate,
      arguments: {
        'community': community,
      },
    );

    if (topic != null) {
      topics.add(topic);
    }
  }

  Future<void> searchTopics(String string_query) async {
    searchDebounceTimer?.cancel();

    searchDebounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {},
    );
  }
}
