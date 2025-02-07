import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_community_card.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
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
        final Color unselectedBg = Theme.of(context).colorScheme.surfaceContainer;
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
                          color: controller.currentTabIndex.value == 0 ? selectedBg : unselectedBg,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Books',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: controller.currentTabIndex.value == 0 ? selectedFg : selectedBg,
                              fontSize: 16,
                            ),
                          ),
                        ),
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
                          color: controller.currentTabIndex.value == 1 ? selectedBg : unselectedBg,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Communities',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: controller.currentTabIndex.value == 1 ? selectedFg : selectedBg,
                              fontSize: 16,
                            ),
                          ),
                        ),
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
                          color: controller.currentTabIndex.value == 2 ? selectedBg : unselectedBg,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Users',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: controller.currentTabIndex.value == 2 ? selectedFg : selectedBg,
                              fontSize: 16,
                            ),
                          ),
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
          appBar: Responsive.isMobile(context) ? AppBar(title: const Text('Search')) : null,
          drawer: Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          body: Column(
            children: [
              Visibility(
                visible: !Responsive.isMobile(context),
                child: const Divider(height: 20),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _tabBar(controller),
              ),
              const Divider(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CommonSearchBar(
                  searchCallback: controller.onQueryChanged,
                  focusNode: FocusNode(),
                ),
              ),
              const Divider(height: 5),
              Expanded(
                child: Obx(
                  () {
                    switch (controller.currentTabIndex.value) {
                      case 0:
                        return CommonGridView<Book>(
                          padding: const EdgeInsets.only(
                            right: 20,
                            left: 20,
                            bottom: 20,
                            top: 5,
                          ),
                          childBuilder: (Book book) {
                            return CommonVerticalBookCard(book: book);
                          },
                          noItemsText: 'No books found in any of the communities you are a part of.',
                          controller: controller.bookListController,
                        );
                      case 1:
                        return CommonListView<Community>(
                          padding: const EdgeInsets.only(
                            right: 20,
                            left: 20,
                            bottom: 20,
                            top: 5,
                          ),
                          childBuilder: (Community community) => CommonCommunityCard(
                            community: community,
                            callback: () {
                              context.push(
                                RouteNames.searchPage +
                                    RouteNames.searchCommunityDetailsPage.replaceFirst(
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
                            right: 20,
                            left: 20,
                            bottom: 20,
                            top: 5,
                          ),
                          childBuilder: (Profile profile) => _userCard(profile),
                          controller: controller.profileListController,
                          noItemsText: 'No users found, likely a network issue.',
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
