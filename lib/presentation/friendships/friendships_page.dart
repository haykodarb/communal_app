import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/friendship.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_pill_button.dart';
import 'package:communal/presentation/common/common_tab_bar.dart';
import 'package:communal/presentation/common/common_user_card.dart';
import 'package:communal/presentation/friendships/friendships_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/presentation/common/common_empty_state.dart';
import 'package:communal/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendshipsPage extends StatelessWidget {
  const FriendshipsPage({super.key});

  List<Widget> _actions(
    Friendship friendship,
    int tab,
    FriendshipsController controller,
  ) {
    switch (tab) {
      case 0:
        return [
          CommonPillButton(
            icon: Atlas.user_minus_bold,
            label: 'Remove'.tr,
            loading: friendship.loading,
            onPressed: (context) => controller.remove(friendship, context),
          ),
        ];
      default:
        return [
          CommonPillButton(
            icon: Icons.check,
            label: 'Accept'.tr,
            filled: true,
            loading: friendship.loading,
            onPressed: (context) => controller.accept(friendship, context),
          ),
          CommonPillButton(
            icon: Icons.close,
            label: 'Reject'.tr,
            loading: friendship.loading,
            onPressed: (context) => controller.reject(friendship, context),
          ),
        ];
    }
  }

  static const List<String> _noItemsTexts = [
    'You have no friends yet.',
    'No pending requests.',
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: FriendshipsController(),
      builder: (FriendshipsController controller) {
        return Scaffold(
          appBar: Responsive.isMobile(context)
              ? AppBar(title: Text('Friends'.tr))
              : null,
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          body: SafeArea(
            child: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: Responsive.isMobile(context) ? 0 : 20,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CommonTabBar(
                      onTabTapped: controller.onTabTapped,
                      currentIndex: controller.currentTabIndex,
                      tabs: ['Friends'.tr, 'Requests'.tr],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 10)),
                Obx(
                  () {
                    final int tab = controller.currentTabIndex.value;

                    return CommonListView<Friendship>(
                      key: ValueKey(tab),
                      padding: const EdgeInsets.only(
                        bottom: 20,
                        left: 10,
                        right: 10,
                      ),
                      isSliver: true,
                      scrollController: controller.scrollController,
                      controller: controller.currentList,
                      noItemsText: _noItemsTexts[tab].tr,
                      emptyState: () => CommonEmptyState(
                        icon: Atlas.users,
                        title: _noItemsTexts[tab].tr,
                        actionLabel: tab == 0 ? 'Search'.tr : null,
                        actionIcon: Atlas.magnifying_glass,
                        onAction: (context) =>
                            context.go(RouteNames.searchPage, extra: 1),
                      ),
                      childBuilder: (Friendship friendship, _) => Obx(
                        () => CommonUserCard(
                          profile: friendship.otherUser,
                          actions: friendship.loading.value
                              ? const [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ]
                              : _actions(friendship, tab, controller),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
