import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityMembersPage extends StatelessWidget {
  const CommunityMembersPage({super.key});

  Widget _userElement(CommunityMembersController controller, Profile user) {
    return Card(
      child: SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Obx(
            () => CommonLoadingBody(
              isLoading: user.loading.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(user.username),
                  Visibility(
                    visible: user.is_admin != null && user.is_admin!,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        border: Border.all(
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      child: const Text('admin'),
                    ),
                  ),
                  Visibility(
                    visible:
                        controller.community.isCurrentUserAdmin != null && controller.community.isCurrentUserAdmin!,
                    child: PopupMenuButton(
                      itemBuilder: (context) {
                        return <PopupMenuEntry>[
                          PopupMenuItem(
                            onTap: () => controller.changeUserAdmin(user, !user.is_admin),
                            child: Text(user.is_admin ? 'Remove as admin' : 'Make admin'),
                          ),
                          PopupMenuItem(
                            onTap: () => controller.removeUser(user),
                            child: const Text('Remove'),
                          ),
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityMembersController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Members'),
          ),
          body: Obx(
            () {
              return CommonLoadingBody(
                isLoading: controller.loading.value,
                child: RefreshIndicator(
                  onRefresh: controller.loadUsers,
                  child: Obx(
                    () => ListView.separated(
                      padding: const EdgeInsets.all(30),
                      itemCount: controller.listOfMembers.length,
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemBuilder: (context, index) {
                        return _userElement(
                          controller,
                          controller.listOfMembers[index],
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
