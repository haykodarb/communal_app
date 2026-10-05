import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/constants.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/community/community_specific/community_books/community_books_page.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_page.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CommunitySpecificPage extends StatelessWidget {
  const CommunitySpecificPage({super.key, required this.communityId});
  final String communityId;

  static const List<IconData> _icons = <IconData>[
    Atlas.book,
    Atlas.chats,
    Atlas.users
  ];

  Widget _tabBarItem(CommunitySpecificController controller, int index) {
    return Builder(
      builder: (context) {
        final List<String> labels = <String>[
          'Books'.tr,
          'Discuss'.tr,
          'Members'.tr
        ];
        return Obx(
          () {
            final bool isSelected = controller.selectedIndex.value == index;

            return Expanded(
              flex: isSelected ? 3 : 2,
              child: InkWell(
                enableFeedback: true,
                onTap: () {
                  if (isSelected) return;
                  controller.selectedIndex.value = index;
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _icons[index],
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                    const VerticalDivider(width: 10),
                    AnimatedOpacity(
                      opacity: isSelected ? 1 : 0,
                      duration: Constants.animationDuration,
                      child: SizedBox(
                        width: isSelected ? null : 0,
                        child: AnimatedSize(
                          duration: Constants.animationDuration,
                          curve: isSelected ? Curves.easeIn : Curves.easeOut,
                          child: Text(
                            labels[index],
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: isSelected ? 14 : 0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
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
      init: CommunitySpecificController(communityId: communityId),
      builder: (controller) {
        return Obx(
          () {
            if (controller.loading.value) return const CommonLoadingBody();

            return Scaffold(
              resizeToAvoidBottomInset: false,
              drawerEnableOpenDragGesture: false,
              extendBody: true,
              appBar: AppBar(
                title: Text(controller.community.name),
                actions: [
                  IconButton(
                    onPressed: () {
                      context.push(
                        '${RouteNames.communityListPage}/$communityId${RouteNames.communitySettingsPage}',
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
                            onPressed: () => controller.discussionsController
                                .goToDiscussionsTopicCreate(context),
                            child: const Icon(Atlas.add_messages),
                          ),
                        ),
                      );
                    case 2:
                      return (controller.community.isCurrentUserAdmin != null &&
                              controller.community.isCurrentUserAdmin!)
                          ? SlideTransition(
                              position: controller.bottomBarAnimation,
                              child: ScaleTransition(
                                scale: controller.floatingActionButtonAnimation,
                                child: FloatingActionButton(
                                  onPressed: () => controller.membersController
                                      .addUser(context),
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
                  dialogTheme: const DialogThemeData(
                    backgroundColor: Colors.transparent,
                  ),
                  splashColor: Colors.transparent,
                ),
                child: SizedBox(
                  width: 300,
                  child: SafeArea(
                    child: SlideTransition(
                      position: controller.bottomBarAnimation,
                      child: Container(
                        color: Colors.transparent,
                        margin: const EdgeInsets.only(
                          bottom: 10,
                          right: 10,
                          left: 10,
                        ),
                        height: 70,
                        constraints: const BoxConstraints.tightFor(width: 200),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
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
                          child: Stack(
                            children: [
                              Obx(() {
                                return AnimatedSlide(
                                  offset: Offset(
                                    controller.selectedIndex.value * 0.66666667,
                                    0,
                                  ),
                                  duration: Constants.animationDuration,
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Container(
                                        width: constraints.maxWidth * (3 / 7),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.15),
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  _icons.length,
                                  (index) {
                                    return _tabBarItem(controller, index);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
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
                        return CommunityBooksPage(
                          communityController: controller,
                        );
                      case 1:
                        return CommunityDiscussionsPage(
                          communityController: controller,
                        );
                      case 2:
                        return CommunityMembersPage(
                          communityController: controller,
                        );
                      default:
                        return const Text('ERROR');
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
