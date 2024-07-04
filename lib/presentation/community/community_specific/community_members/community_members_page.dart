import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityMembersPage extends StatelessWidget {
  const CommunityMembersPage({super.key});

  Widget _userElement(CommunityMembersController controller, Profile user) {
    return Card(
      child: InkWell(
        onTap: user.id == UsersBackend.currentUserId
            ? null
            : () {
                Get.toNamed(
                  RouteNames.profileOtherPage,
                  arguments: {
                    'user': user,
                  },
                );
              },
        enableFeedback: false,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: EdgeInsets.only(left: 20, right: user.id == UsersBackend.currentUserId ? 20 : 10),
            child: Obx(
              () => CommonLoadingBody(
                loading: user.loading.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(user.username),
                    Visibility(
                      visible: user.is_admin,
                      child: Builder(
                        builder: (context) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: const Text('admin'),
                          );
                        },
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        if (user.id == UsersBackend.currentUserId) {
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                20,
                              ),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: const Text('you'),
                          );
                        }

                        if (controller.community.isCurrentUserAdmin != null &&
                            controller.community.isCurrentUserAdmin!) {
                          return PopupMenuButton(
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
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
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
          floatingActionButton: controller.community.isCurrentUserAdmin!
              ? FloatingActionButton(
                  onPressed: () {
                    Get.toNamed(
                      RouteNames.communityInvitePage,
                      arguments: {
                        'community': controller.community,
                      },
                    );
                  },
                  child: const Icon(Atlas.user_plus),
                )
              : null,
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              child: RefreshIndicator(
                onRefresh: controller.loadUsers,
                child: Obx(
                  () => ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: controller.listOfMembers.length,
                    separatorBuilder: (context, index) {
                      return const Divider(height: 0);
                    },
                    itemBuilder: (context, index) {
                      final Profile member = controller.listOfMembers[index];
                      return Row(
                        children: [
                          Expanded(
                            child: _userElement(
                              controller,
                              member,
                            ),
                          ),
                          Visibility(
                            visible: member.id != UsersBackend.currentUserId,
                            child: const VerticalDivider(width: 5),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            height: 60,
                            child: Visibility(
                              visible: member.id != UsersBackend.currentUserId,
                              child: IconButton(
                                onPressed: () {
                                  Get.toNamed(
                                    RouteNames.messagesSpecificPage,
                                    arguments: {
                                      'user': member,
                                    },
                                  );
                                },
                                icon: Icon(
                                  Atlas.comment_dots,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
