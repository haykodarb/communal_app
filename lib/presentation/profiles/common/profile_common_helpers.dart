import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileCommonHelpers {
  static Widget tabBarView({
    required RxInt currentTabIndex,
    required CommonListViewController<Book> bookListController,
    required CommonListViewController<Loan> reviewListController,
    required ScrollController scrollController,
    required Widget Function(Book) bookCardBuilder,
    required Widget Function(Loan) reviewCardBuilder,
    String booksNoItemsText = 'No books.',
    String reviewsNoItemsText = 'No reviews.',
  }) {
    return Obx(
      () {
        if (currentTabIndex.value == 0) {
          return CommonGridView<Book>(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            controller: bookListController,
            scrollController: scrollController,
            noItemsText: booksNoItemsText,
            isSliver: true,
            childBuilder: bookCardBuilder,
          );
        }

        if (currentTabIndex.value == 1) {
          return CommonListView<Loan>(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            controller: reviewListController,
            scrollController: scrollController,
            noItemsText: reviewsNoItemsText,
            isSliver: true,
            childBuilder: reviewCardBuilder,
          );
        }

        return const SliverFillRemaining(
          hasScrollBody: false,
          fillOverscroll: false,
          child: Center(
            child: Text('Error.'),
          ),
        );
      },
    );
  }

  static Widget buildProfileHeader({
    required Widget avatarRow,
    required bool showBio,
    required Widget bio,
  }) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 20),
          avatarRow,
          const Divider(height: 10),
          Visibility(
            visible: showBio,
            child: bio,
          ),
          const Divider(height: 10),
          // ProfileCommonWidgets.loanCount(),
          const Divider(height: 10),
        ],
      ),
    );
  }

  static Widget buildTabBarAppBar({
    required Widget tabBar,
  }) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      forceMaterialTransparency: true,
      scrolledUnderElevation: 0,
      title: Padding(
        padding: const EdgeInsetsGeometry.symmetric(
          horizontal: 10,
        ),
        child: tabBar,
      ),
      titleSpacing: 0,
      toolbarHeight: 80,
      centerTitle: true,
      automaticallyImplyLeading: false,
      pinned: true,
    );
  }
}
