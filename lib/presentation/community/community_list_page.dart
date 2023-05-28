import 'package:biblioteca/models/community.dart';
import 'package:biblioteca/presentation/common/common_scaffold/common_scaffold_widget.dart';
import 'package:biblioteca/presentation/community/community_list_controller.dart';
import 'package:biblioteca/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityListPage extends StatelessWidget {
  const CommunityListPage({super.key});

  Widget _communityCard(CommunityListController controller, Community community) {
    return Card(
      child: InkWell(
        onTap: () => controller.goToCommunitySpecific(community),
        child: SizedBox(
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(community.name),
              Text(community.description),
            ],
          ),
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
            child: const Icon(Icons.add),
            onPressed: () {
              Get.toNamed(
                RouteNames.communityCreatePage,
              );
            },
          ),
          appBar: AppBar(
            title: const Text('Communities'),
          ),
          drawer: const CommonScaffoldWidget(),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.loading.value) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    return RefreshIndicator(
                      onRefresh: controller.fetchAllCommunities,
                      child: Obx(
                        () {
                          if (controller.communities.isNotEmpty) {
                            return ListView.separated(
                              itemCount: controller.communities.length,
                              physics: const AlwaysScrollableScrollPhysics(
                                parent: BouncingScrollPhysics(),
                              ),
                              separatorBuilder: (context, index) => const Divider(),
                              itemBuilder: (context, index) {
                                return _communityCard(
                                  controller,
                                  controller.communities[index],
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text(
                                'You haven\'t joined\nany communities yet.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 18),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
