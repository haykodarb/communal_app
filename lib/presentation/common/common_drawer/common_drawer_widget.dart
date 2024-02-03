import 'package:atlas_icons/atlas_icons.dart';
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
                    selected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onBackground;

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
                        height: 50,
                        child: Text(
                          text,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
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
                                // color: Theme.of(context).colorScheme.primary,
                                border: Border.all(color: Theme.of(context).colorScheme.primary),
                              ),
                              child: Text(
                                notifications.value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
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
    return GetBuilder(
      init: _commonDrawerController,
      builder: (CommonDrawerController controller) {
        final Color dividerColor = Theme.of(context).colorScheme.surface;

        return Drawer(
          elevation: 20,
          child: Container(
            color: Theme.of(context).colorScheme.background,
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
                        text: 'Profile',
                        icon: Atlas.account,
                        selected: Get.currentRoute == RouteNames.profileOwnPage,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.profileOwnPage),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'Messages',
                        icon: Atlas.chats,
                        selected: Get.currentRoute == RouteNames.messagesPage,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.messagesPage),
                        notifications: _commonDrawerController.messageNotifications,
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'My Books',
                        icon: Atlas.library,
                        selected: Get.currentRoute == RouteNames.bookListPage,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.bookListPage),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'My Tools',
                        selected: Get.currentRoute == RouteNames.toolListPage,
                        icon: Icons.handyman_outlined,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.toolListPage),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'Communities',
                        selected: Get.currentRoute == RouteNames.communityListPage,
                        icon: Atlas.users,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.communityListPage),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'Invitations',
                        selected: Get.currentRoute == RouteNames.invitationsPage,
                        icon: Atlas.envelope_paper_email,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.invitationsPage),
                        notifications: _commonDrawerController.invitationsNotifications,
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'Loans',
                        selected: Get.currentRoute == RouteNames.loansPage,
                        icon: Atlas.account_arrows,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.loansPage),
                        notifications: _commonDrawerController.loanNotifications,
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        selected: false,
                        icon: Get.isDarkMode ? Atlas.sunny : Atlas.moon,
                        text: Get.isDarkMode ? 'Light' : 'Dark',
                        callback: _commonDrawerController.changeThemeMode,
                      ),
                      const Expanded(child: SizedBox()),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'Logout',
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
