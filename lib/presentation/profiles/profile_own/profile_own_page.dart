import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliver_tools/sliver_tools.dart';

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

  Widget _tabBar(ProfileOwnController controller) {
    return Builder(
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            padding: const EdgeInsets.all(5),
            height: 60,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.primary,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.primary,
              dividerColor: Colors.transparent,
              onTap: (value) => controller.onTabBarChange,
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
        pagingController: PagingController.fromValue(PagingState(itemList: controller.userBooks), firstPageKey: 0),
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

  Widget _reviewsTab(ProfileOwnController controller) {
    final List<int> list = List.generate(
      2,
      (index) => index,
    );

    return Padding(
      padding: const EdgeInsets.only(right: 10, left: 10),
      child: PagedMasonryGridView.count(
        pagingController: PagingController.fromValue(PagingState(itemList: list), firstPageKey: 0),
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        crossAxisCount: 2,
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
            return Text('$index');
          },
        ),
      ),
    );
  }

  Widget _tabBarView(ProfileOwnController controller) {
    return Builder(
      builder: (BuildContext context) {
        return Obx(
          () => CommonLoadingBody(
            loading: controller.loading.value,
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _bookTab(controller),
                _reviewsTab(controller),
              ],
            ),
          ),
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
          appBar: AppBar(title: const Text('My Profile')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Get.toNamed(
              RouteNames.profileOwnEditPage,
              arguments: {
                'profile': UsersBackend.currentUserProfile.value,
              },
            ),
            child: const Icon(Atlas.pencil),
          ),
          drawer: CommonDrawerWidget(),
          body: DefaultTabController(
            length: 2,
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const ClampingScrollPhysics(),
                overscroll: false,
              ),
              child: ExtendedNestedScrollView(
                controller: controller.scrollController,
                physics: const NeverScrollableScrollPhysics(),
                onlyOneScrollInBody: true,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverOverlapAbsorber(
                      handle: ExtendedNestedScrollView.sliverOverlapAbsorberHandleFor(context),
                      sliver: SliverSafeArea(
                        sliver: MultiSliver(
                          children: [
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _avatarRow(controller),
                                  const Divider(height: 10),
                                  _bio(controller),
                                  const Divider(height: 10),
                                  _loanCount(controller),
                                ],
                              ),
                            ),
                            SliverAppBar(
                              flexibleSpace: FlexibleSpaceBar(
                                background: _tabBar(controller),
                              ),
                              toolbarHeight: 60,
                              centerTitle: true,
                              automaticallyImplyLeading: false,
                              floating: true,
                              pinned: true,
                            ),
                          ],
                        ),
                      ),
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
