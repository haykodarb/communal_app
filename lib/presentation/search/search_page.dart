import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_community_card.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/search/search_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

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
                        alignment: Alignment.center,
                        child: Text(
                          'Books',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: controller.currentTabIndex.value == 0 ? selectedFg : selectedBg,
                            fontSize: 16,
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
                        alignment: Alignment.center,
                        child: Text(
                          'Communities',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: controller.currentTabIndex.value == 1 ? selectedFg : selectedBg,
                            fontSize: 16,
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
                        alignment: Alignment.center,
                        child: Text(
                          'Users',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: controller.currentTabIndex.value == 2 ? selectedFg : selectedBg,
                            fontSize: 16,
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
          appBar: AppBar(
            title: const Text('Search'),
          ),
          drawer: Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _tabBar(controller),
                const Divider(height: 10),
                CommonSearchBar(
                  searchCallback: controller.onQueryChanged,
                  focusNode: FocusNode(),
                ),
                const Divider(height: 10),
                Expanded(
                  child: Obx(
                    () {
                      switch (controller.currentTabIndex.value) {
                        case 0:
                          return CommonGridView<Book>(
                            padding: EdgeInsets.zero,
                            childBuilder: (Book book) {
                              return CommonVerticalBookCard(book: book);
                            },
                            controller: controller.bookListController,
                          );
                        case 1:
                          return CommonListView<Community>(
                            padding: EdgeInsets.zero,
                            childBuilder: (Community community) => CommonCommunityCard(
                              community: community,
                              callback: () {},
                            ),
                            controller: controller.communityListController,
                          );
                        case 2:
                          return CommonListView<Profile>(
                            padding: EdgeInsets.zero,
                            childBuilder: (Profile profile) => Text(profile.username),
                            controller: controller.profileListController,
                          );
                        default:
                          return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
