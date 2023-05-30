import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_scaffold/common_scaffold_widget.dart';
import 'package:communal/presentation/community/community_list_controller.dart';
import 'package:communal/routes.dart';
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
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Obx(
                  () {
                    return CommonLoadingBody(
                      isLoading: controller.loading.value,
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
