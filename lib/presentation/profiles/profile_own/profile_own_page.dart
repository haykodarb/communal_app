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
import 'package:communal/presentation/profiles/profile_own/profile_own_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class ProfileOwnPage extends StatelessWidget {
  const ProfileOwnPage({super.key});

  Widget _editProfileButton() {
    return CommonButton(
      type: CommonButtonType.outlined,
      expand: false,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Atlas.pencil_bold,
            size: 16,
          ),
          const VerticalDivider(width: 4),
          Text(
            'Edit profile'.tr,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onPressed: (BuildContext context) async {
        context.push(
          RouteNames.profileOwnPage + RouteNames.profileOwnEditPage,
        );
      },
    );
  }

  Widget _avatarRow({
    required Profile profile,
    required IconData icon,
    required VoidCallback onIconPressed,
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
                          fit: BoxFit.scaleDown,
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
                          _editProfileButton(),
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
      init: ProfileOwnController(),
      builder: (ProfileOwnController controller) {
        return Scaffold(
          extendBody: true,
          appBar: Responsive.isMobile(context)
              ? AppBar(title: Text('My Profile'.tr))
              : null,
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          body: SafeArea(
            child: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                ProfileCommonHelpers.buildProfileHeader(
                  avatarRow: Obx(() {
                    if (controller.commonDrawerController.currentUserProfile
                        .value.id.isEmpty) {
                      return const SizedBox();
                    }

                    return _avatarRow(
                      profile: controller
                          .commonDrawerController.currentUserProfile.value,
                      icon: Atlas.pencil,
                      onIconPressed: () {
                        context.push(
                          RouteNames.profileOwnPage +
                              RouteNames.profileOwnEditPage,
                        );
                      },
                    );
                  }),
                  showBio: controller.commonDrawerController.currentUserProfile
                          .value.bio !=
                      null,
                  bio: Obx(
                    () => ProfileCommonWidgets.bio(
                      controller
                          .commonDrawerController.currentUserProfile.value,
                    ),
                  ),
                ),
                ProfileCommonHelpers.buildTabBarAppBar(
                  tabBar: CommonTabBar(
                    currentIndex: controller.currentTabIndex,
                    onTabTapped: controller.onTabTapped,
                    tabs: const ['Books', 'Reviews'],
                  ),
                ),
                ProfileCommonHelpers.tabBarView(
                  currentTabIndex: controller.currentTabIndex,
                  bookListController: controller.bookListController,
                  reviewListController: controller.reviewListController,
                  scrollController: controller.scrollController,
                  bookCardBuilder: (Book book) => InkWell(
                    onTap: () {
                      context.push('${RouteNames.myBooks}/${book.id}');
                    },
                    child: CommonVerticalBookCard(
                      book: book,
                    ),
                  ),
                  reviewCardBuilder: (Loan loan) =>
                      ProfileCommonWidgets.reviewCard(
                    loan: loan,
                    onTap: () {
                      context.push('${RouteNames.loansPage}/${loan.id}');
                    },
                  ),
                  booksNoItemsText:
                      'You have not uploaded any books.\n\nYou can start doing so from the "My Books" page.',
                  reviewsNoItemsText:
                      'You have not reviews any books yet.\n\nYou can leave reviews on books you loan from other people.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
