import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/discussion.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_controller.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommunityDiscussionsPage extends StatelessWidget {
  const CommunityDiscussionsPage({super.key, required this.communityController});

  final CommunitySpecificController communityController;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityDiscussionsController(),
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: controller.goToDiscussionsTopicCreate,
            child: const Icon(
              Atlas.add_messages,
            ),
          ),
          body: SafeArea(
            child: Obx(
              () => CommonLoadingBody(
                loading: controller.loading.value,
                child: Obx(
                  () {
                    if (controller.topics.isEmpty) {
                      return const Center(
                        child: SizedBox(
                          height: 100,
                          width: 300,
                          child: Text(
                            'There are have been no topics created in this community yet.\nBe the first!',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: controller.topics.length,
                      padding: const EdgeInsets.all(20),
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
