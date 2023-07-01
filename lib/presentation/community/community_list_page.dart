import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/community/community_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityListPage extends StatelessWidget {
  const CommunityListPage({super.key});

  Widget _communityCard(CommunityListController controller, Community community) {
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        onTap: () => controller.goToCommunitySpecific(community),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: FutureBuilder(
                future: CommunitiesBackend.getCommunityAvatar(community),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CommonLoadingImage();
                  }

                  if (snapshot.data!.isEmpty) {
                    return Container(
                      color: Get.theme.colorScheme.primary,
                      child: Icon(
                        Icons.groups,
                        color: Get.theme.colorScheme.background,
                        size: 150,
                      ),
                    );
                  }

                  return Image.memory(
                    snapshot.data!,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            SizedBox(
              height: 70,
              child: Center(
                child: Text(
                  community.name,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityListController(),
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: controller.goToCommunityCreate,
            child: const Icon(Icons.add),
          ),
          appBar: AppBar(
            title: const Text('Communities'),
          ),
          drawer: CommonDrawerWidget(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(
                  () => CommonLoadingBody(
                    loading: controller.loading.value,
                    child: RefreshIndicator(
                      onRefresh: controller.fetchAllCommunities,
                      child: Obx(
                        () {
                          if (controller.communities.isNotEmpty) {
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
                              itemCount: controller.communities.length,
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                return _communityCard(
                                  controller,
                                  controller.communities[index],
                                );
                              },
                            );
                          } else {
                            return const CustomScrollView(
                              slivers: [
                                SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      'You have not joined\nany communities yet.',
                                      style: TextStyle(fontSize: 16),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
