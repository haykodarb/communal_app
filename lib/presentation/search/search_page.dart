import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_user_card.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/common/common_tab_bar.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/search/search_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/presentation/common/common_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key, this.initialTab = 0});

  /// 0: Books, 1: Users. Links pass it as the route's `extra`.
  final int initialTab;

  /// A zero-result search echoes the query back, instead of the generic
  /// "nothing here" wording shown with no query typed at all.
  static String _emptyMessage(String query, String match, String fallback) {
    final String trimmed = query.trim();
    return trimmed.isEmpty
        ? fallback.tr
        : match.tr.replaceFirst('{query}', trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SearchPageController(initialTab: initialTab),
      builder: (SearchPageController controller) {
        return Scaffold(
          appBar: Responsive.isMobile(context)
              ? AppBar(title: Text('Search'.tr))
              : null,
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          body: SafeArea(
            child: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: Responsive.isMobile(context) ? 0 : 20,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CommonTabBar(
                      onTabTapped: controller.onTabTapped,
                      currentIndex: controller.currentTabIndex,
                      tabs: [
                        'Books'.tr,
                        'Users'.tr,
                      ],
                    ),
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
                          maxColumns: 3,
                          padding: const EdgeInsets.only(
                            bottom: 20,
                            left: 10,
                            right: 10,
                          ),
                          isSliver: true,
                          scrollController: controller.scrollController,
                          childBuilder: (Book book) =>
                              CommonVerticalBookCard(book: book),
                          noItemsText:
                              'No books found among your friends and their friends.'
                                  .tr,
                          emptyState: () => CommonEmptyState(
                            icon: Atlas.magnifying_glass,
                            title: _emptyMessage(
                              controller.query,
                              'No books match "{query}"',
                              'No books found among your friends and their friends.',
                            ),
                          ),
                          controller: controller.bookListController,
                        );
                      case 1:
                        return CommonListView<Profile>(
                          padding: const EdgeInsets.only(
                            bottom: 20,
                            left: 10,
                            right: 10,
                          ),
                          isSliver: true,
                          scrollController: controller.scrollController,
                          childBuilder: (Profile profile, _) => CommonUserCard(
                            profile: profile,
                          ),
                          controller: controller.profileListController,
                          noItemsText: 'No users found.'.tr,
                          emptyState: () => CommonEmptyState(
                            icon: Atlas.magnifying_glass,
                            title: _emptyMessage(
                              controller.query,
                              'No users match "{query}"',
                              'No users found.',
                            ),
                          ),
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
