import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/community/community_specific/community_books/community_books_page.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_page.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificPage extends StatelessWidget {
  const CommunitySpecificPage({super.key});

  static const List<IconData> _icons = <IconData>[
    Atlas.book,
    Atlas.chats,
    Atlas.users
  ];

  static const List<String> _labels = <String>['Books', 'Discuss', 'Members'];

  Widget _tabBarItem(CommunitySpecificController controller, int index) {
    return Builder(
      builder: (context) {
        return Obx(
          () {
            final bool isSelected = controller.selectedIndex.value == index;

            if (!isSelected) {
              return Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  return InkWell(
                    enableFeedback: true,
                    onTap: () {
                      controller.selectedIndex.value = index;
                    },
                    child: SizedBox(
                      width: 40,
                      child: Icon(
                        _icons[index],
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }),
              );
            }

            return Container(
              height: double.maxFinite,
              width: 150,
              decoration: BoxDecoration(
                // color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _icons[index],
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    size: 24,
                  ),
                  const VerticalDivider(width: 5),
                  Text(
                    _labels[index],
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificController(),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          extendBody: true,
          appBar: AppBar(
            title: Text(controller.community.name),
            actions: [
              IconButton(
                onPressed: () {
                  Get.toNamed(
                    RouteNames.communitySettingsPage,
                    arguments: {
                      'community': controller.community,
                    },
                  );
                },
                icon: const Icon(
                  Atlas.gear,
                ),
                iconSize: 24,
              )
            ],
          ),
          floatingActionButton: Obx(
            () {
              switch (controller.selectedIndex.value) {
                case 1:
                  return SlideTransition(
                    position: controller.bottomBarAnimation,
                    child: ScaleTransition(
                      scale: controller.floatingActionButtonAnimation,
                      child: FloatingActionButton(
                        onPressed: controller
                            .discussionsController.goToDiscussionsTopicCreate,
                        child: const Icon(Atlas.add_messages),
                      ),
                    ),
                  );
                case 2:
                  return controller.community.isCurrentUserAdmin!
                      ? SlideTransition(
                          position: controller.bottomBarAnimation,
                          child: ScaleTransition(
                            scale: controller.floatingActionButtonAnimation,
                            child: FloatingActionButton(
                              onPressed: controller.membersController.addUser,
                              child: const Icon(Atlas.user_plus),
                            ),
                          ),
                        )
                      : const SizedBox.shrink();
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              highlightColor: Colors.transparent,
              dialogBackgroundColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: SafeArea(
              child: SlideTransition(
                position: controller.bottomBarAnimation,
                child: Container(
                  color: Colors.transparent,
                  margin:
                      const EdgeInsets.only(bottom: 10, right: 10, left: 10),
                  height: 70,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 0),
                          blurRadius: 1,
                          spreadRadius: 1,
                          color: Theme.of(context).colorScheme.shadow,
                        ),
                      ],
                    ),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Stack(
                        children: [
                          Obx(
                            () {
                              final int index = controller.selectedIndex.value;

                              final double offset =
                                  ((constraints.maxWidth - 150) / 2) / 150;

                              return AnimatedSlide(
                                offset: Offset(offset * index, 0),
                                curve: Curves.linear,
                                duration: const Duration(milliseconds: 0),
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(40),
                                  ),
                                ),
                              );
                            },
                          ),
                          Row(
                            children: List.generate(
                              _labels.length,
                              (index) {
                                return _tabBarItem(controller, index);
                              },
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            bottom: false,
            maintainBottomViewPadding: false,
            child: Obx(
              () {
                switch (controller.selectedIndex.value) {
                  case 0:
                    return CommunityBooksPage(communityController: controller);
                  case 1:
                    return CommunityDiscussionsPage(
                        communityController: controller);
                  case 2:
                    return CommunityMembersPage(
                        communityController: controller);
                  default:
                    return const Text('ERROR');
                }
              },
            ),
          ),
        );
      },
    );
  }
}
