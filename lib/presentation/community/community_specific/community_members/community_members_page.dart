import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_controller.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:communal/routes.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityMembersPage extends StatelessWidget {
  const CommunityMembersPage({super.key, required this.communityController});

  final CommunitySpecificController communityController;

  Widget _searchRow(CommunityMembersController controller) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CommonSearchBar(
            searchCallback: (String _) {},
            focusNode: FocusNode(),
          ),
        );
      },
    );
  }

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
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Obx(
              () => CommonLoadingBody(
                loading: user.loading.value,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CommonCircularAvatar(
                      profile: user,
                      radius: 20,
                      clickable: true,
                    ),
                    const VerticalDivider(width: 10),
                    Expanded(
                      child: Text(
                        user.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
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
      init: communityController.membersController,
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
              loading: controller.loading.value,
              child: Obx(
                () => ListView.separated(
                  padding: const EdgeInsets.all(10),
                  itemCount: controller.listOfMembers.length,
                  separatorBuilder: (context, index) {
                    return const Divider(height: 5);
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
        );
      },
    );
  }
}
