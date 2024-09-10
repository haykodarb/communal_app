import 'package:communal/models/discussion.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_controller.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommunityDiscussionsPage extends StatelessWidget {
  const CommunityDiscussionsPage(
      {super.key, required this.communityController});

  final CommunitySpecificController communityController;

  Widget _searchRow(CommunityDiscussionsController controller) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CommonSearchBar(
          searchCallback: controller.searchTopics,
          focusNode: controller.focusScope,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: communityController.discussionsController,
      builder: (controller) {
        return ExtendedNestedScrollView(
          floatHeaderSlivers: true,
          controller: communityController.scrollController,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: _searchRow(controller),
                titleSpacing: 0,
                toolbarHeight: 55,
                centerTitle: true,
                automaticallyImplyLeading: false,
                floating: true,
              ),
            ];
          },
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.firstLoad.value,
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
                    padding: const EdgeInsets.all(10),
                    separatorBuilder: (context, index) {
                      return const Divider(height: 5);
                    },
                    itemBuilder: (context, index) {
                      final DiscussionTopic topic = controller.topics[index];

                      return InkWell(
                        onTap: () => controller.goToTopicMessages(topic),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic.name,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600),
                                ),
                                const Divider(height: 15),
                                Visibility(
                                  visible: topic.last_message == null,
                                  child: Container(
				  alignment: Alignment.bottomLeft,
                                    height: 50,
                                    child: Text(
                                      'Empty',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible: topic.last_message != null,
                                  child: Row(
                                    children: [
                                      CommonCircularAvatar(
                                        profile: topic.last_message?.sender ??
                                            Profile.empty(),
                                        radius: 25,
                                      ),
                                      const VerticalDivider(width: 10),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          mainAxisSize: MainAxisSize.max,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    topic.last_message?.sender
                                                            .username ??
                                                        '',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat.MMMEd().format(
                                                    topic.last_message
                                                            ?.created_at ??
                                                        DateTime.now(),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(height: 0),
                                            Text(
                                              topic.last_message?.content ?? '',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
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
        );
      },
    );
  }
}
