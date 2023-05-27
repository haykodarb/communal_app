import 'package:biblioteca/backend/communities_backend.dart';
import 'package:biblioteca/presentation/community/community_specific/community_specific_controller.dart';
import 'package:biblioteca/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificPage extends StatelessWidget {
  const CommunitySpecificPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(controller.community.name),
          ),
          endDrawer: SafeArea(
            child: Drawer(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Center(
                  child: Column(
                    children: [
                      Text('Users:'),
                      Expanded(
                        child: Obx(
                          () {
                            return ListView.separated(
                              itemCount: controller.usersInCommunity.length,
                              itemBuilder: (context, index) {
                                return Text(controller.usersInCommunity[index].username);
                              },
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                            );
                          },
                        ),
                      ),
                      FutureBuilder(
                        future: CommunitiesBackend.isUserAdmin(controller.community),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null && snapshot.data!) {
                            return ElevatedButton(
                                onPressed: () {
                                  Get.toNamed(
                                    RouteNames.communityInvitePage,
                                    arguments: {
                                      'community': controller.community,
                                    },
                                  );
                                },
                                child: Text('Invite user'));
                          }

                          return SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: Column(),
        );
      },
    );
  }
}
