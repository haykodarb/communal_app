import 'package:biblioteca/presentation/common/scaffold_drawer/scaffold_drawer.dart';
import 'package:biblioteca/presentation/communities/communities_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitiesPage extends StatelessWidget {
  const CommunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitiesController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Communities'),
          ),
          drawer: const ScaffoldDrawer(),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Obx(
                    () {
                      if (controller.loading.value) {
                        return const Center(
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (controller.communities.isNotEmpty) {
                        return ListView.builder(
                          itemCount: controller.communities.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Text(controller.communities[index].name),
                                Text(controller.communities[index].description),
                              ],
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
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.goToCreateCommunity,
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
