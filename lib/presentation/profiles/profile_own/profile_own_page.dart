import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
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
          body: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              ProfileCommonHelpers.buildProfileHeader(
                avatarRow: Obx(() {
                  if (controller.commonDrawerController.currentUserProfile.value
                      .id.isEmpty) {
                    return const SizedBox();
                  }

                  return ProfileCommonWidgets.avatarRow(
                    profile: controller
                        .commonDrawerController.currentUserProfile.value,
                    icon: Atlas.pencil,
                    onIconPressed: () {
                      context.push(
                        RouteNames.profileOwnPage +
                            RouteNames.profileOwnEditPage,
                      );
                    },
                    isOwnProfile: true,
                  );
                }),
                showBio: controller
                        .commonDrawerController.currentUserProfile.value.bio !=
                    null,
                bio: Obx(
                  () => ProfileCommonWidgets.bio(
                    controller.commonDrawerController.currentUserProfile.value,
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
        );
      },
    );
  }
}
