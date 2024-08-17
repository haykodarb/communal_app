import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/user_preferences.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonDrawerWidget extends StatelessWidget {
  CommonDrawerWidget({super.key});

  final CommonDrawerController _commonDrawerController = Get.find<CommonDrawerController>();

  Widget _drawerButton({
    required IconData icon,
    required String text,
    required void Function() callback,
    required bool selected,
    RxInt? notifications,
  }) {
    return Column(
      children: [
        MaterialButton(
          onPressed: callback,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Builder(
              builder: (context) {
                final Color color =
                    selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      icon,
                      color: color,
                    ),
                    const VerticalDivider(),
                    Expanded(
                      flex: 4,
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: 30,
                        child: Text(
                          text,
                          style: TextStyle(color: color),
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
                                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1.5),
                              ),
                              child: Text(
                                notifications.value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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
          ),
        ),
      ],
    );
  }

  Widget _drawerHeader() {
    return SizedBox(
      height: 150,
      child: DrawerHeader(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        child: Builder(
          builder: (context) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
              width: double.maxFinite,
              color: Theme.of(context).colorScheme.surface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Obx(() => CommonCircularAvatar(profile: UsersBackend.currentUserProfile.value, radius: 40)),
                  const VerticalDivider(),
                  Obx(
                    () => Text(
                      UsersBackend.currentUserProfile.value.username,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
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
      init: _commonDrawerController,
      builder: (CommonDrawerController controller) {
        final Color dividerColor = Theme.of(context).colorScheme.surface;

        return Drawer(
          elevation: 20,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _drawerHeader(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Divider(
                        thickness: 0,
                        color: Colors.transparent,
                        height: 10,
                      ),
                      _drawerButton(
                        text: 'profile'.tr,
                        icon: Atlas.account,
                        selected: Get.currentRoute == RouteNames.profileOwnPage,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.profileOwnPage),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        text: 'notifications'.tr,
                        icon: Atlas.bell,
                        selected: Get.currentRoute == RouteNames.notificationsPage,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.notificationsPage),
                        notifications: _commonDrawerController.globalNotifications,
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        text: 'messages'.tr,
                        icon: Atlas.chats,
                        selected: Get.currentRoute == RouteNames.messagesPage,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.messagesPage),
                        notifications: _commonDrawerController.messageNotifications,
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        text: 'my-books'.tr,
                        icon: Atlas.library,
                        selected: Get.currentRoute == RouteNames.bookListPage,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.bookListPage),
                      ),
                      // Divider(
                      //   thickness: 2,
                      //   color: dividerColor,
                      //   height: dividerHeight,
                      // ),
                      // _drawerButton(
                      //   text: 'my-tools'.tr,
                      //   selected: Get.currentRoute == RouteNames.toolListPage,
                      //   icon: Icons.handyman_outlined,
                      //   callback: () => _commonDrawerController.goToRoute(RouteNames.toolListPage),
                      // ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        text: 'communities'.tr,
                        selected: Get.currentRoute == RouteNames.communityListPage,
                        icon: Atlas.users,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.communityListPage),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        text: 'loans'.tr,
                        selected: Get.currentRoute == RouteNames.loansPage,
                        icon: Atlas.account_arrows,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.loansPage),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        selected: false,
                        icon: Get.isDarkMode ? Atlas.sunny : Atlas.moon,
                        text: Get.isDarkMode ? 'light'.tr : 'dark'.tr,
                        callback: _commonDrawerController.changeThemeMode,
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        selected: false,
                        icon: Atlas.language_translation,
                        text: Get.locale == const Locale('es', 'ES') ? 'Español' : 'English',
                        callback: () async {
                          final Locale newLocale = Get.locale == const Locale('es', 'ES')
                              ? const Locale('en', 'US')
                              : const Locale('es', 'ES');

                          await Get.updateLocale(newLocale);
                          await UserPreferences.setSelectedLocale(newLocale);
                        },
                      ),
                      const Expanded(child: SizedBox()),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                        height: dividerHeight,
                      ),
                      _drawerButton(
                        text: 'logout'.tr,
                        selected: false,
                        icon: Atlas.double_arrow_right_circle,
                        callback: _commonDrawerController.handleLogout,
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
