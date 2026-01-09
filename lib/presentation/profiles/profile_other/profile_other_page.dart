import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
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
                    avatarRow: ProfileCommonWidgets.avatarRow(
                      profile: controller.profile.value,
                      icon: Atlas.message,
                      onIconPressed: () => context.push(
                        '${RouteNames.messagesPage}/${controller.profile.value.id}',
                        extra: {
                          'ownerId': controller.profile.value.id,
                        },
                      ),
                      isOwnProfile: false,
                    ),
                    showBio: controller.profile.value.bio != null,
                    bio: ProfileCommonWidgets.bio(controller.profile.value),
                  );
                },
              ),
              ProfileCommonHelpers.buildTabBarAppBar(
                tabBar: ProfileCommonWidgets.tabBar(
                  currentTabIndex: controller.currentTabIndex,
                  onTabTapped: controller.onTabTapped,
                  useTranslations: false,
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
