import 'dart:math';

import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_community_card.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/common/common_tab_bar.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/search/search_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  Widget _userCard(Profile user) {
    return Builder(
      builder: (context) {
        return Card(
          child: InkWell(
            onTap: () {
              context.push(
                RouteNames.profileOtherPage.replaceFirst(
                  ':userId',
                  user.id,
                ),
              );
            },
            enableFeedback: false,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: SizedBox(
              height: 60,
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
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
                    const VerticalDivider(width: 10),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _tabBar(SearchPageController controller) {
    return Builder(
      builder: (BuildContext context) {
        final Color selectedBg = Theme.of(context).colorScheme.primary;
        final Color selectedFg = Theme.of(context).colorScheme.onPrimary;
        final Color unselectedBg =
            Theme.of(context).colorScheme.surfaceContainer;
        return Container(
          padding: const EdgeInsets.all(10),
          height: 70,
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => controller.onTabTapped(0),
                  child: Obx(
                    () {
                      return Container(
                        decoration: BoxDecoration(
                          color: controller.currentTabIndex.value == 0
                              ? selectedBg
                              : unselectedBg,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        alignment: Alignment.center,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Text(
                            'Books'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: controller.currentTabIndex.value == 0
                                  ? selectedFg
                                  : selectedBg,
                              fontSize:
                                  min(30, max(constraints.maxWidth * 0.09, 14)),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => controller.onTabTapped(1),
                  child: Obx(
                    () {
                      return Container(
                        decoration: BoxDecoration(
                          color: controller.currentTabIndex.value == 1
                              ? selectedBg
                              : unselectedBg,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        alignment: Alignment.center,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Text(
                            'Communities'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: controller.currentTabIndex.value == 1
                                  ? selectedFg
                                  : selectedBg,
                              fontSize:
                                  min(30, max(constraints.maxWidth * 0.09, 14)),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => controller.onTabTapped(2),
                  child: Obx(
                    () {
                      return Container(
                        decoration: BoxDecoration(
                          color: controller.currentTabIndex.value == 2
                              ? selectedBg
                              : unselectedBg,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        alignment: Alignment.center,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Text(
                              'Users'.tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: controller.currentTabIndex.value == 2
                                    ? selectedFg
                                    : selectedBg,
                                fontSize: min(
                                    30, max(constraints.maxWidth * 0.09, 14)),
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SearchPageController(),
      builder: (SearchPageController controller) {
        return Scaffold(
          appBar: Responsive.isMobile(context)
              ? AppBar(title: const Text('Search'))
              : null,
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child:
                      SizedBox(height: Responsive.isMobile(context) ? 0 : 20)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Obx(() {
                    return CommonTabBar(
                      onTabTapped: controller.onTabTapped,
                      currentIndex: controller.currentTabIndex,
                      tabs: const [
                        'Books',
                        'Communities',
                        'Users',
                      ],
                    );
                  }),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 5)),
              SliverAppBar(
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: CommonSearchBar(
                    searchCallback: controller.onQueryChanged,
                    focusNode: FocusNode(),
                  ),
                ),
                titleSpacing: 0,
                toolbarHeight: 60,
                centerTitle: true,
                automaticallyImplyLeading: false,
                pinned: true,
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 5)),
              Obx(
                () {
                  switch (controller.currentTabIndex.value) {
                    case 0:
                      return CommonGridView<Book>(
                        padding: const EdgeInsets.only(
                          bottom: 20,
                          left: 10,
                          right: 10,
                        ),
                        isSliver: true,
                        childBuilder: (Book book) =>
                            CommonVerticalBookCard(book: book),
                        noItemsText:
                            'No books found in any of the communities you are a part of.',
                        controller: controller.bookListController,
                      );
                    case 1:
                      return CommonListView<Community>(
                        padding: const EdgeInsets.only(
                          bottom: 20,
                          left: 10,
                          right: 10,
                        ),
                        isSliver: true,
                        childBuilder: (Community community) =>
                            CommonCommunityCard(
                          community: community,
                          callback: () {
                            context.push(
                              RouteNames.searchPage +
                                  RouteNames.searchCommunityDetailsPage
                                      .replaceFirst(
                                    ':communityId',
                                    community.id,
                                  ),
                            );
                          },
                        ),
                        controller: controller.communityListController,
                      );
                    case 2:
                      return CommonListView<Profile>(
                        padding: const EdgeInsets.only(
                          bottom: 20,
                          left: 10,
                          right: 10,
                        ),
                        isSliver: true,
                        childBuilder: (Profile profile) => _userCard(profile),
                        controller: controller.profileListController,
                        noItemsText: 'No users found, likely a network issue.',
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
