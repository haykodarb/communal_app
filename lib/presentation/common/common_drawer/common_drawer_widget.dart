import 'dart:math' as math;

import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/login_backend.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class _DrawerItem {
  const _DrawerItem(this.route, this.text, this.icon, [this.notifications]);

  final String route;
  final String text;
  final IconData icon;
  final RxInt? notifications;
}

class CommonDrawerWidget extends StatelessWidget {
  const CommonDrawerWidget({super.key});

  static const int _rowFlex = 2;

  /// The 80px avatar plus 20px above and below, under the status bar. On
  /// tall screens the header grows to [_headerShare] of the drawer.
  static const double _headerMinHeight = 120;
  static const double _headerShare = 0.18;

  Widget _drawerButton({
    required IconData icon,
    required String text,
    required void Function() callback,
    required bool selected,
    RxInt? notifications,
  }) {
    return Expanded(
      flex: _rowFlex,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: MaterialButton(
              onPressed: callback,
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
              child: LayoutBuilder(builder: (context, constraints) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: constraints.maxHeight * 0.2,
                  ),
                  child: Builder(
                    builder: (context) {
                      final Color color = selected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Icon(
                              icon,
                              size: 26,
                              color: color,
                            ),
                          ),
                          const VerticalDivider(),
                          Expanded(
                            flex: 4,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                text,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Builder(builder: (context) {
                            if (notifications == null) return const SizedBox();
                            return Obx(
                              () {
                                if (notifications.value != 0) {
                                  return Container(
                                    width: 25,
                                    height: 25,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Text(
                                      notifications.value.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            );
                          }),
                        ],
                      );
                    },
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Your avatar and name, and "View profile": the whole header opens My
  /// Profile (there's no Profile row). On the drawer's own background.
  Widget _drawerHeader(
    CommonDrawerController controller,
    double drawerHeight,
  ) {
    return Builder(
      builder: (context) {
        final ColorScheme colors = Theme.of(context).colorScheme;
        final double top = MediaQuery.paddingOf(context).top;

        return InkWell(
          onTap: () =>
              controller.goToRoute(RouteNames.profileOwnPage, context),
          child: Container(
            height: math.max(
              _headerMinHeight + top,
              drawerHeight * _headerShare,
            ),
            // Clear of the status bar, as DrawerHeader was.
            padding: EdgeInsets.fromLTRB(30, top, 30, 0),
            width: double.maxFinite,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                Obx(
                  () {
                    if (controller.currentUserProfile.value.id.isEmpty) {
                      return Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.hardEdge,
                        height: 40 * 2,
                        width: 40 * 2,
                        child: const CommonLoadingImage(),
                      );
                    }

                    return CommonCircularAvatar(
                      profile: controller.currentUserProfile.value,
                      radius: 40,
                    );
                  },
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.currentUserProfile.value.username,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'View profile'.tr,
                            style: TextStyle(
                              color: colors.primary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 18 / 14,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: colors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const double dividerHeight = 7.5;

    return SafeArea(
      top: false,
      child: GetBuilder(
        init: Get.find<CommonDrawerController>(),
        global: true,
        builder: (CommonDrawerController controller) {
          final Color dividerColor = Theme.of(context).colorScheme.surface;
          final Widget divider = Divider(
            thickness: 2,
            color: dividerColor,
            height: dividerHeight,
          );

          // Profile is the header; Loans is reached from Home's "See all".
          // Communities is hidden while the feature is off.
          final List<_DrawerItem> items = [
            _DrawerItem(RouteNames.homePage, 'Home'.tr, Atlas.home),
            _DrawerItem(
              RouteNames.searchPage,
              'Search'.tr,
              Atlas.magnifying_glass,
            ),
            _DrawerItem(
              RouteNames.notificationsPage,
              'Notifications'.tr,
              Atlas.bell,
              controller.globalNotifications,
            ),
            _DrawerItem(
              RouteNames.messagesPage,
              'Messages'.tr,
              Atlas.chats,
              controller.messageNotifications,
            ),
            _DrawerItem(
              RouteNames.friendsPage,
              'Friends'.tr,
              Atlas.users,
              controller.friendRequests,
            ),
            _DrawerItem(RouteNames.myBooks, 'My Books'.tr, Atlas.library),
            _DrawerItem(RouteNames.settingsPage, 'Settings'.tr, Atlas.gear),
          ];

          return Drawer(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0),
            ),
            elevation: 20,
            child: Container(
              color: Theme.of(context).colorScheme.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _drawerHeader(controller, MediaQuery.sizeOf(context).height),
                  for (final _DrawerItem item in items) ...[
                    divider,
                    Obx(
                      () => _drawerButton(
                        text: item.text,
                        icon: item.icon,
                        selected: controller.currentRoute.value == item.route,
                        callback: () =>
                            controller.goToRoute(item.route, context),
                        notifications: item.notifications,
                      ),
                    ),
                  ],
                  const Expanded(
                    flex: 3 * _rowFlex,
                    child: SizedBox(),
                  ),
                  divider,
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    width: double.maxFinite,
                    child: Obx(
                      () => Text(
                        controller.versionNumber.value,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  divider,
                  _drawerButton(
                    text: 'Logout'.tr,
                    selected: false,
                    icon: Atlas.double_arrow_right_circle,
                    callback: () async {
                      await LoginBackend.logout();
                      Get.deleteAll();
                      if (context.mounted) {
                        context.go(RouteNames.startPage);
                      }
                    },
                  ),
                  const Divider(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
