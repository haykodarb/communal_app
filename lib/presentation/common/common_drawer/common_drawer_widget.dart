import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CommonDrawerWidget extends StatelessWidget {
  const CommonDrawerWidget({super.key});

  Widget _drawerButton({
    required IconData icon,
    required String text,
    required void Function() callback,
    required bool selected,
    RxInt? notifications,
  }) {
    return Expanded(
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
                                          width: 1.5),
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

  Widget _drawerHeader(CommonDrawerController controller) {
    return SizedBox(
      height: 150,
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Builder(
          builder: (context) {
            return InkWell(
              onTap: () =>
                  controller.goToRoute(RouteNames.profileOwnPage, context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                width: double.maxFinite,
                color: Theme.of(context).colorScheme.surface,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Obx(() {
                      if (controller.currentUserProfile.value.id.isEmpty) {
                        return const SizedBox();
                      }

                      return CommonCircularAvatar(
                        profile: controller.currentUserProfile.value,
                        radius: 40,
                        clickable: true,
                      );
                    }),
                    const VerticalDivider(width: 20),
                    Expanded(
                      child: Obx(
                        () => Text(
                          controller.currentUserProfile.value.username,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double dividerHeight = 7.5;

    return GetBuilder(
      init: Get.find<CommonDrawerController>(),
      global: true,
      builder: (CommonDrawerController controller) {
        final Color dividerColor = Theme.of(context).colorScheme.surface;
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
                _drawerHeader(controller),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Divider(
                        thickness: 0,
                        color: Colors.transparent,
                        height: dividerHeight,
                      ),
                      Obx(() {
                        return _drawerButton(
                          text: 'Profile'.tr,
                          icon: Atlas.account,
                          selected: controller.currentRoute.value ==
                              RouteNames.profileOwnPage,
                          callback: () => controller.goToRoute(
                              RouteNames.profileOwnPage, context),
                        );
                      }),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      Obx(() {
                        return _drawerButton(
                          text: 'Notifications'.tr,
                          icon: Atlas.bell,
                          selected: controller.currentRoute.value ==
                              RouteNames.notificationsPage,
                          callback: () => controller.goToRoute(
                            RouteNames.notificationsPage,
                            context,
                          ),
                          notifications: controller.globalNotifications,
                        );
                      }),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      Obx(() {
                        return _drawerButton(
                          text: 'Search'.tr,
                          icon: Atlas.magnifying_glass,
                          selected: controller.currentRoute.value ==
                              RouteNames.searchPage,
                          callback: () => controller.goToRoute(
                            RouteNames.searchPage,
                            context,
                          ),
                        );
                      }),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      Obx(
                        () {
                          return _drawerButton(
                            text: 'Messages'.tr,
                            icon: Atlas.chats,
                            selected: controller.currentRoute.value ==
                                RouteNames.messagesPage,
                            callback: () => controller.goToRoute(
                                RouteNames.messagesPage, context),
                            notifications: controller.messageNotifications,
                          );
                        },
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      Obx(
                        () {
                          return _drawerButton(
                            text: 'My Books'.tr,
                            icon: Atlas.library,
                            selected: controller.currentRoute.value ==
                                RouteNames.myBooks,
                            callback: () => controller.goToRoute(
                                RouteNames.myBooks, context),
                          );
                        },
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      Obx(
                        () {
                          return _drawerButton(
                            text: 'Communities'.tr,
                            selected: controller.currentRoute.value ==
                                RouteNames.communityListPage,
                            icon: Atlas.users,
                            callback: () => controller.goToRoute(
                              RouteNames.communityListPage,
                              context,
                            ),
                          );
                        },
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      Obx(
                        () {
                          return _drawerButton(
                            text: 'Loans'.tr,
                            selected: controller.currentRoute.value ==
                                RouteNames.loansPage,
                            icon: Atlas.account_arrows,
                            callback: () => controller.goToRoute(
                              RouteNames.loansPage,
                              context,
                            ),
                          );
                        },
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        selected: false,
                        icon: UserPreferences.isDarkMode(context)
                            ? Atlas.sunny
                            : Atlas.moon,
                        text: UserPreferences.isDarkMode(context)
                            ? 'Light'.tr
                            : 'Dark'.tr,
                        callback: () => controller.changeThemeMode(context),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        selected: false,
                        icon: Atlas.language_translation,
                        text: Get.locale == const Locale('es', 'ES')
                            ? 'English'
                            : 'Español',
                        callback: () async {
                          final Locale newLocale =
                              Get.locale == const Locale('es', 'ES')
                                  ? const Locale('en', 'US')
                                  : const Locale('es', 'ES');

                          await Get.updateLocale(newLocale);
                          await UserPreferences.setSelectedLocale(newLocale);
                        },
                      ),
                      const Expanded(
                        flex: 3,
                        child: SizedBox(),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      Container(
                        padding: const EdgeInsets.only(left: 20),
                        width: double.maxFinite,
                        child: Obx(
                          () => Text(
                            controller.versionNumber.value,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
