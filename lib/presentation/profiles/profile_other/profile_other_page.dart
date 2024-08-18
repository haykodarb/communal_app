import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/profiles/profile_other/profile_other_controller.dart';
import 'package:communal/routes.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class ProfileOtherPage extends StatelessWidget {
  const ProfileOtherPage({super.key});

  Widget _avatarRow(Profile profile) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            children: [
              CommonCircularAvatar(
                profile: profile,
                radius: 37.5,
              ),
              const VerticalDivider(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        profile.username,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: profile.email != null,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text(
                          profile.email ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bio(Profile profile) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About me',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 5),
              Text(
                profile.bio ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _loanCount(ProfileOtherController controller) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '56 items borrowed',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '32 items lent',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _tabBar(ProfileOtherController controller) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 70,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 0),
                  blurRadius: 2,
                  spreadRadius: 2,
                  color: Theme.of(context).colorScheme.shadow,
                ),
              ],
            ),
            child: TabBar(
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Theme.of(context).colorScheme.primary,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              dividerColor: Colors.transparent,
              onTap: (value) => controller.onTabTapped(value),
              isScrollable: false,
              tabs: const [
                Tab(
                  height: 50,
                  text: 'Books',
                ),
                Tab(
                  height: 50,
                  text: 'Reviews',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bookTab(ProfileOtherController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
      child: PagedMasonryGridView.count(
        pagingController: PagingController.fromValue(
          PagingState(itemList: controller.userBooks),
          firstPageKey: 0,
        ),
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        crossAxisCount: 2,
        physics: const NeverScrollableScrollPhysics(),
        builderDelegate: PagedChildBuilderDelegate(
          noItemsFoundIndicatorBuilder: (context) {
            return const SizedBox(
              height: 100,
              child: Center(child: Text('No items found')),
            );
          },
          itemBuilder: (context, item, index) {
            final Book book = controller.userBooks[index];

            return CommonKeepaliveWrapper(
              child: InkWell(
                onTap: () {
                  Get.toNamed(
                    RouteNames.bookOwnedPage,
                    arguments: {'book': book},
                  );
                },
                child: CommonVerticalBookCard(
                  book: book,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _reviewCard(Loan loan) {
    return Builder(
      builder: (context) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.book.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const Divider(height: 5),
                          Text(
                            loan.book.author,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const Divider(height: 5),
                          Text(
                            '${DateFormat('MMM d, y', Get.locale?.languageCode).format(loan.returned_at!).capitalizeFirst}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: CommonBookCover(loan.book),
                    ),
                  ],
                ),
                Text(
                  loan.review!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reviewsTab(ProfileOtherController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
      child: PagedListView.separated(
        pagingController: PagingController.fromValue(PagingState(itemList: controller.userReviews), firstPageKey: 0),
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        separatorBuilder: (context, index) => const Divider(),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        builderDelegate: PagedChildBuilderDelegate(
          noItemsFoundIndicatorBuilder: (context) {
            return Container(
              height: 100,
              color: Colors.red.shade100,
              child: const Text('No items found'),
            );
          },
          itemBuilder: (context, item, index) {
            final Loan loan = controller.userReviews[index];
            return CommonKeepaliveWrapper(child: _reviewCard(loan));
          },
        ),
      ),
    );
  }

  Widget _tabBarView(ProfileOtherController controller) {
    return Builder(
      builder: (BuildContext context) {
        return TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Obx(
              () => CommonLoadingBody(
                loading: controller.loadingBooks.value,
                child: _bookTab(controller),
              ),
            ),
            Obx(
              () => CommonLoadingBody(
                loading: controller.loadingReviews.value,
                child: _reviewsTab(controller),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ProfileOtherController(),
      builder: (ProfileOtherController controller) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                onPressed: () => Get.toNamed(
                  RouteNames.messagesSpecificPage,
                  arguments: {
                    'user': controller.profile.value,
                  },
                ),
                iconSize: 24,
                icon: const Icon(Atlas.message),
              ),
            ],
          ),
          body: DefaultTabController(
            length: 2,
            animationDuration: Duration.zero,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const ClampingScrollPhysics(),
                overscroll: false,
              ),
              child: Obx(
                () => CommonLoadingBody(
                  loading: controller.loadingProfile.value,
                  child: ExtendedNestedScrollView(
                    controller: controller.scrollController,
                    key: controller.nestedScrollViewKey,
                    physics: const NeverScrollableScrollPhysics(),
                    onlyOneScrollInBody: true,
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => _avatarRow(controller.profile.value),
                              ),
                              const Divider(height: 10),
                              Obx(
                                () => Visibility(
                                  visible: controller.profile.value.bio != null,
                                  child: _bio(controller.profile.value),
                                ),
                              ),
                              const Divider(height: 10),
                              _loanCount(controller),
                              const Divider(height: 10),
                            ],
                          ),
                        ),
                        SliverAppBar(
                          backgroundColor: Colors.transparent,
                          forceMaterialTransparency: true,
                          scrolledUnderElevation: 0,
                          title: _tabBar(controller),
                          titleSpacing: 0,
                          toolbarHeight: 80,
                          centerTitle: true,
                          automaticallyImplyLeading: false,
                          floating: true,
                          pinned: true,
                        ),
                      ];
                    },
                    body: _tabBarView(controller),
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
