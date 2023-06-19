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

  final RxBool loading = false.obs;

  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getDiscussionTopics();
  }

  Future<void> getDiscussionTopics() async {
    loading.value = true;

    final BackendResponse response = await DiscussionsBackend.getDiscussionTopicsForCommunity(community);

    if (response.success) {
      topics.value = response.payload;
    }

    loading.value = false;
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
}
