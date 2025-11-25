import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/profiles/profile_other/profile_other_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ProfileOtherPage extends StatelessWidget {
  const ProfileOtherPage({
    super.key,
    required this.userId,
  });

  final String userId;

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
              IconButton(
                onPressed: () => context.push(
                  '${RouteNames.messagesPage}/${profile.id}',
                  extra: {
                    'ownerId': profile.id,
                  },
                ),
                iconSize: 24,
                icon: const Icon(Atlas.message),
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
                'About me'.tr,
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

  // ignore: unused_element
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
        final Color selectedBg = Theme.of(context).colorScheme.primary;
        final Color selectedFg = Theme.of(context).colorScheme.onPrimary;
        final Color unselectedBg =
            Theme.of(context).colorScheme.surfaceContainer;
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
                          child: Text(
                            'Books',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: controller.currentTabIndex.value == 0
                                  ? selectedFg
                                  : selectedBg,
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
                            color: controller.currentTabIndex.value == 1
                                ? selectedBg
                                : unselectedBg,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Reviews',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: controller.currentTabIndex.value == 1
                                  ? selectedFg
                                  : selectedBg,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const Divider(height: 5),
                          Text(
                            loan.book.author,
                            style: TextStyle(
                              fontSize: 14,
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
                              fontSize: 14,
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
                const Divider(height: 20),
                Text(
                  loan.review!,
                  style: const TextStyle(
                    fontSize: 14,
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

  Widget _tabBarView(ProfileOtherController controller, BuildContext context) {
    return Obx(
      () {
        if (controller.currentTabIndex.value == 0) {
          return CommonGridView<Book>(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            controller: controller.bookListController,
            scrollController: controller.scrollController,
            noItemsText: 'No books.',
            isSliver: true,
            childBuilder: (Book book) => CommonVerticalBookCard(
              book: book,
            ),
          );
        }

        if (controller.currentTabIndex.value == 1) {
          return CommonListView<Loan>(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            controller: controller.reviewListController,
            scrollController: controller.scrollController,
            noItemsText: 'No reviews.',
            isSliver: true,
            childBuilder: (Loan loan) => _reviewCard(loan),
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      tag: userId,
      init: ProfileOtherController(userId: userId),
      builder: (ProfileOtherController controller) {
        return Scaffold(
          extendBody: true,
          appBar: Responsive.isMobile(context)
              ? AppBar(title: const Text('Profile'))
              : (GoRouter.of(context).canPop()
                  ? AppBar(title: const Text('Profile'))
                  : null),
          drawer: Responsive.isMobile(context)
              ? (GoRouter.of(context).canPop()
                  ? null
                  : const CommonDrawerWidget())
              : null,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(
                        height: Responsive.isMobile(context) || context.canPop()
                            ? 0
                            : 20),
                    Obx(
                      () {
                        if (controller.loadingProfile.value) {
                          return const SizedBox.shrink();
                        }

                        return _avatarRow(
                          controller.profile.value,
                        );
                      },
                    ),
                    const Divider(height: 10),
                    Obx(
                      () => Visibility(
                        visible: controller.profile.value.bio != null,
                        child: _bio(
                          controller.profile.value,
                        ),
                      ),
                    ),
                    const Divider(height: 10),
                    // _loanCount(controller),
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
                pinned: true,
              ),
              _tabBarView(controller, context),
            ],
          ),
        );
      },
    );
  }
}
