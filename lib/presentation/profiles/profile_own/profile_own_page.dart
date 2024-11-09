import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_responsive_page.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:intl/intl.dart';

class ProfileOwnPage extends StatelessWidget {
  const ProfileOwnPage({super.key});

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
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
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
              labelStyle:
                  const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
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
    return PagedMasonryGridView.count(
      pagingController: controller.booksPagingController,
      mainAxisSpacing: 5,
      crossAxisSpacing: 5,
      padding: const EdgeInsets.only(top: 10, bottom: 20, right: 10, left: 10),
      crossAxisCount: 2,
      builderDelegate: PagedChildBuilderDelegate(
        noItemsFoundIndicatorBuilder: (context) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('No items found')),
          );
        },
        itemBuilder: (context, Book item, index) {
          return CommonKeepaliveWrapper(
            child: InkWell(
              onTap: () {
                context.push('${RouteNames.myBooks}/${item.id}');
              },
              child: CommonVerticalBookCard(
                book: item,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _reviewCard(Loan loan) {
    return Builder(
      builder: (context) {
        return Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const Divider(height: 5),
                          Text(
                            '${DateFormat('MMM d, y', Get.locale?.languageCode).format(loan.latest_date!).capitalizeFirst}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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

  Widget _reviewsTab(ProfileOwnController controller) {
    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
      child: ListView.separated(
        itemCount: controller.userReviews.length,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        separatorBuilder: (context, index) => const Divider(height: 5),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final Loan loan = controller.userReviews[index];
          return CommonKeepaliveWrapper(child: _reviewCard(loan));
        },
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
        return CommonResponsivePage(
          child: Scaffold(
            extendBody: true,
            appBar: AppBar(
              title: const Text(
                'My Profile',
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    context.go(
                      RouteNames.profileOwnPage + RouteNames.profileOwnEditPage,
                    );
                  },
                  iconSize: 24,
                  icon: const Icon(Atlas.pencil),
                ),
              ],
            ),
            drawer: Responsive.isMobile(context) ? CommonDrawerWidget() : null,
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
                  onlyOneScrollInBody: true,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => _avatarRow(
                                UsersBackend.currentUserProfile.value)),
                            const Divider(height: 10),
                            Obx(
                              () => Visibility(
                                visible:
                                    UsersBackend.currentUserProfile.value.bio !=
                                        null,
                                child:
                                    _bio(UsersBackend.currentUserProfile.value),
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
                        title: _tabBar(controller, innerBoxIsScrolled),
                        titleSpacing: 0,
                        toolbarHeight: 80,
                        centerTitle: true,
                        automaticallyImplyLeading: false,
                        pinned: true,
                      ),
                    ];
                  },
                  body: _tabBarView(controller),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
