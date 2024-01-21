import 'package:communal/models/discussion.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommunityDiscussionsPage extends StatelessWidget {
  const CommunityDiscussionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityDiscussionsController(),
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: controller.goToDiscussionsTopicCreate,
            child: const Icon(
              Icons.add,
            ),
          ),
          body: SafeArea(
            child: Obx(
              () => CommonLoadingBody(
                loading: controller.loading.value,
                child: Obx(
                  () {
                    return ListView.separated(
                      itemCount: controller.topics.length,
                      padding: const EdgeInsets.all(20),
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemBuilder: (context, index) {
                        final DiscussionTopic topic = controller.topics[index];

                        return InkWell(
                          onTap: () => controller.goToTopicMessages(topic),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topic.name,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const Divider(height: 30),
                                  Row(
                                    children: [
                                      const Text('Created by '),
                                      CommonUsernameButton(user: topic.creator),
                                      const Text(' on '),
                                      Text(DateFormat.yMMMd().format(topic.created_at.toLocal()))
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
