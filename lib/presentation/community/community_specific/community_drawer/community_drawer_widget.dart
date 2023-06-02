import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/community/community_specific/community_drawer/community_drawer_controller.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class CommunityDrawerWidget extends StatelessWidget {
  const CommunityDrawerWidget({
    super.key,
    required this.community,
  });

  final Community community;

  Widget _drawerHeader() {
    return SizedBox(
      height: 100,
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Container(
          padding: const EdgeInsets.all(8),
          width: double.maxFinite,
          color: Get.theme.colorScheme.surface,
          child: Center(
            child: Text(
              community.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Get.theme.colorScheme.onSurface,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerButton({
    required IconData icon,
    required String text,
    required void Function() callback,
  }) {
    final BuildContext context = Get.context!;
    return Column(
      children: [
        MaterialButton(
          onPressed: callback,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Icon(
                  icon,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  alignment: Alignment.centerLeft,
                  height: 50,
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Divider(
          thickness: 2,
          color: Theme.of(context).colorScheme.surface,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityDrawerController(community),
      builder: (controller) {
        return SafeArea(
          child: Drawer(
            backgroundColor: Get.theme.colorScheme.background,
            child: Center(
              child: Obx(
                () {
                  return CommonLoadingBody(
                    isLoading: controller.loading.value,
                    child: Column(
                      children: [
                        _drawerHeader(),
                        _drawerButton(
                          icon: Icons.people,
                          text: 'Members',
                          callback: () {
                            Get.toNamed(
                              RouteNames.communityMembersPage,
                              arguments: {
                                'community': community,
                              },
                            );
                          },
                        ),
                        _drawerButton(
                          icon: Icons.forum,
                          text: 'Discussions',
                          callback: () {},
                        ),
                        Visibility(
                          visible: community.isCurrentUserAdmin != null && community.isCurrentUserAdmin!,
                          child: _drawerButton(
                            icon: Icons.person_add,
                            text: 'Invite',
                            callback: () {
                              Get.toNamed(
                                RouteNames.communityInvitePage,
                                arguments: {
                                  'community': community,
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
