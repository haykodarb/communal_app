import 'dart:async';
import 'package:communal/backend/discussions_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/discussion.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunityDiscussionsController extends GetxController {
  CommunityDiscussionsController({required this.communityId});

  final TextEditingController textEditingController = TextEditingController();

  final String communityId;
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
    _subscription ??=
        RealtimeBackend.streamController.stream.listen(streamListener);

    getDiscussionTopics();
  }

  @override
  Future<void> onClose() async {
    await _subscription?.cancel();

    super.onClose();
  }

  Future<void> streamListener(RealtimeMessage realtimeMessage) async {
    print(realtimeMessage.new_row);

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
        await DiscussionsBackend.getDiscussionTopicsForCommunity(communityId);

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

  Future<void> goToTopicMessages(
      DiscussionTopic topic, BuildContext context) async {
    context.go(
      '${RouteNames.communityListPage}/$communityId/discussions/${topic.id}',
    );
  }

  Future<void> goToDiscussionsTopicCreate(BuildContext context) async {
    context.go(
      '${RouteNames.communityListPage}/$communityId/discussions/create',
    );
  }

  Future<void> searchTopics(String string_query) async {
    searchDebounceTimer?.cancel();

    searchDebounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {},
    );
  }
}
