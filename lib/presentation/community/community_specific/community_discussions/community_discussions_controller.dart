import 'dart:async';

import 'package:communal/backend/discussions_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/discussion.dart';
import 'package:communal/routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class CommunityDiscussionsController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();

  final Community community = Get.arguments['community'];

  final RxList<DiscussionTopic> topics = <DiscussionTopic>[].obs;

  final RxList<DiscussionMessage> messages = <DiscussionMessage>[].obs;

  final RxBool firstLoad = false.obs;
  final RxBool loadingMore = false.obs;

  final RxString errorMessage = ''.obs;

  final FocusNode focusScope = FocusNode();

  Timer? searchDebounceTimer;
  Timer? loadMoreDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    getDiscussionTopics();
  }

  Future<void> getDiscussionTopics() async {
    firstLoad.value = true;

    final BackendResponse response = await DiscussionsBackend.getDiscussionTopicsForCommunity(community);

    if (response.success) {
      topics.value = response.payload;
    }

    firstLoad.value = false;
  }

  Future<void> goToTopicMessages(DiscussionTopic topic) async {
    Get.toNamed(
      RouteNames.communityDiscussionsTopicMessages,
      arguments: {'topic': topic},
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
