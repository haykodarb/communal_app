import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class ProfileOwnPage extends StatelessWidget {
  const ProfileOwnPage({super.key});

  Widget _avatarRow(ProfileOwnController controller) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Row(
            children: [
              CommonCircularAvatar(
                profile: UsersBackend.currentUserProfile.value,
                radius: 37.5,
              ),
              const VerticalDivider(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => Text(
                      UsersBackend.currentUserProfile.value.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Obx(
                    () => Text(
                      UsersBackend.currentUserProfile.value.email ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bio(ProfileOwnController controller) {
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
              Obx(
                () => Text(
                  UsersBackend.currentUserProfile.value.bio ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _loanCount(ProfileOwnController controller) {
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

  Widget _tabBar(ProfileOwnController controller, bool shadow) {
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
                  blurRadius: shadow ? 2 : 0,
                  spreadRadius: shadow ? 2 : 0,
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

  Widget _bookTab(ProfileOwnController controller) {
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
                            '${loan.book?.title}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const Divider(height: 5),
                          Text(
                            '${loan.book?.author}',
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: FutureBuilder(
                            future: BooksBackend.getBookCover(loan.book!),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CommonLoadingImage();
                              }

                              return Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                        ),
                      ),
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

  Widget _reviewsTab(ProfileOwnController controller) {
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

  Widget _tabBarView(ProfileOwnController controller) {
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
      init: ProfileOwnController(),
      builder: (ProfileOwnController controller) {
        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                onPressed: () => Get.toNamed(
                  RouteNames.profileOwnEditPage,
                  arguments: {
                    'profile': UsersBackend.currentUserProfile.value,
                  },
                ),
                iconSize: 24,
                icon: const Icon(Atlas.pencil),
              ),
            ],
          ),
          drawer: CommonDrawerWidget(),
          body: DefaultTabController(
            length: 2,
            animationDuration: Duration.zero,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const ClampingScrollPhysics(),
                overscroll: false,
              ),
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
                          _avatarRow(controller),
                          const Divider(height: 10),
                          _bio(controller),
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
                      title: _tabBar(controller, innerBoxIsScrolled),
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
        );
      },
    );
  }
}
