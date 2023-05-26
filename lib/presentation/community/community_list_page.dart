import 'package:biblioteca/models/community.dart';
import 'package:biblioteca/presentation/common/common_scaffold/common_scaffold_widget.dart';
import 'package:biblioteca/presentation/community/community_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityListPage extends StatelessWidget {
  const CommunityListPage({super.key});

  Widget _communityCard(Community community) {
    return Card(
      child: InkWell(
        onTap: () {},
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
          appBar: AppBar(
            title: const Text('Communities'),
          ),
          drawer: const CommonScaffoldWidget(),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.loading.value) {
                      return const Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
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
                                  controller.communities[index],
                                );
                              },
                            );
                          } else {
                            return const Center(
                              child: Text('You have joined\nno communities yet.'),
                            );
                          }
                        },
                      ),
                    );
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.goToCommunityCreate,
                          child: const Text('New'),
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Invites'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
