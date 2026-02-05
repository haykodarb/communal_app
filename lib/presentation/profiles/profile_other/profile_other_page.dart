import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_tab_bar.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/profiles/common/profile_common_helpers.dart';
import 'package:communal/presentation/profiles/common/profile_common_widgets.dart';
import 'package:communal/presentation/profiles/profile_other/profile_other_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class ProfileOtherPage extends StatelessWidget {
  const ProfileOtherPage({
    super.key,
    required this.userId,
  });

  final String userId;

  Widget _removeFriendButton(
      Profile profile, ProfileOtherController controller) {
    final bool isPending = profile.friendship?.isAccepted ?? false;

    return CommonButton(
      type: CommonButtonType.outlined,
      expand: false,
      loading: controller.loadingFriendship,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      loaderSize: 20,
      onPressed: controller.deleteFriendship,
      child: Visibility(
        visible: isPending,
        replacement: Row(
          children: [
            const Icon(
              Atlas.user_minus_bold,
              size: 16,
            ),
            const VerticalDivider(width: 4),
            Text(
              'Pending'.tr,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Atlas.user_check_bold,
              size: 16,
            ),
            const VerticalDivider(width: 4),
            Text(
              'Friends'.tr,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addFriendButton(Profile profile, ProfileOtherController controller) {
    return CommonButton(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      expand: false,
      loaderSize: 20,
      loading: controller.loadingFriendship,
      onPressed: controller.createFriendship,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Atlas.user_plus_bold,
            size: 18,
          ),
          const VerticalDivider(width: 4),
          Text(
            'Add friend'.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageUserButton(Profile profile) {
    return AspectRatio(
      aspectRatio: 1,
      child: CommonButton(
        type: profile.friendship != null
            ? CommonButtonType.filledIcon
            : CommonButtonType.outlinedIcon,
        expand: false,
        onPressed: (BuildContext context) {
          context.push(
            '${RouteNames.messagesPage}/${profile.id}',
          );
        },
        child: const Icon(
          Atlas.comment_dots_bold,
          size: 16,
        ),
      ),
    );
  }

  Widget _avatarRow({
    required Profile profile,
    required IconData icon,
    required VoidCallback onIconPressed,
    required ProfileOtherController controller,
  }) {
    const int avatarHeight = 105;

    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          height: avatarHeight + 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonCircularAvatar(
                profile: profile,
                radius: avatarHeight / 2,
              ),
              const VerticalDivider(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 35,
                      child: Row(
                        children: [
                          Visibility(
                            visible: profile.friendship == null,
                            replacement: _removeFriendButton(
                              profile,
                              controller,
                            ),
                            child: _addFriendButton(
                              profile,
                              controller,
                            ),
                          ),
                          const VerticalDivider(width: 8),
                          _messageUserButton(profile),
                          const Expanded(child: SizedBox()),
                        ],
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
              Obx(
                () {
                  if (controller.loadingProfile.value) {
                    return const SliverToBoxAdapter(
                      child: SizedBox.shrink(),
                    );
                  }

                  return ProfileCommonHelpers.buildProfileHeader(
                    avatarRow: _avatarRow(
                      profile: controller.profile.value,
                      controller: controller,
                      icon: Atlas.message,
                      onIconPressed: () => context.push(
                        '${RouteNames.messagesPage}/${controller.profile.value.id}',
                        extra: {
                          'ownerId': controller.profile.value.id,
                        },
                      ),
                    ),
                    showBio: controller.profile.value.bio != null,
                    bio: ProfileCommonWidgets.bio(controller.profile.value),
                  );
                },
              ),
              ProfileCommonHelpers.buildTabBarAppBar(
                tabBar: CommonTabBar(
                  currentIndex: controller.currentTabIndex,
                  onTabTapped: controller.onTabTapped,
                  tabs: ['Books'.tr, 'Reviews'.tr],
                ),
              ),
              ProfileCommonHelpers.tabBarView(
                currentTabIndex: controller.currentTabIndex,
                bookListController: controller.bookListController,
                reviewListController: controller.reviewListController,
                scrollController: controller.scrollController,
                bookCardBuilder: (Book book) => CommonVerticalBookCard(
                  book: book,
                ),
                reviewCardBuilder: (Loan loan) =>
                    ProfileCommonWidgets.reviewCard(
                  loan: loan,
                  onTap: null,
                ),
                booksNoItemsText: 'No books.',
                reviewsNoItemsText: 'No reviews.',
              ),
            ],
          ),
        );
      },
    );
  }
}
