import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonDrawerWidget extends StatelessWidget {
  CommonDrawerWidget({Key? key}) : super(key: key);

  final CommonDrawerController _commonDrawerController = Get.find<CommonDrawerController>();

  Widget _drawerButton({
    required IconData icon,
    required String text,
    required void Function() callback,
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
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      icon,
                      color: Theme.of(context).colorScheme.onBackground,
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
                            color: Theme.of(context).colorScheme.onBackground,
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
                                // color: Theme.of(context).colorScheme.secondary,
                                border: Border.all(color: Theme.of(context).colorScheme.secondary),
                              ),
                              child: Text(
                                notifications.value.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.secondary,
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
                  CommonCircularAvatar(username: _commonDrawerController.username, radius: 40),
                  const VerticalDivider(),
                  Text(
                    _commonDrawerController.username,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 18,
                    ),
                  )
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
                        thickness: 2,
                        color: Colors.transparent,
                      ),
                      // _drawerButton(
                      //   text: 'Profile',
                      //   icon: Icons.person_rounded,
                      //   callback: () {},
                      // ),
                      // _drawerButton(
                      //   text: 'Notifications',
                      //   icon: Icons.notifications,
                      //   callback: () {},
                      // ),

                      // Divider(
                      //   thickness: 2,
                      //   color: dividerColor,
                      // ),
                      _drawerButton(
                        text: 'Messages',
                        icon: Icons.sms,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.messagesPage),
                        notifications: _commonDrawerController.messageNotifications,
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'Books',
                        icon: Icons.menu_book,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.bookListPage),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'Communities',
                        icon: Icons.people_alt_outlined,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.communityListPage),
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'Invitations',
                        icon: Icons.mail,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.invitationsPage),
                        notifications: _commonDrawerController.invitationsNotifications,
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        text: 'Loans',
                        icon: Icons.outbox,
                        callback: () => _commonDrawerController.goToRoute(RouteNames.loansPage),
                        notifications: _commonDrawerController.loanNotifications,
                      ),
                      Divider(
                        thickness: 2,
                        color: dividerColor,
                      ),
                      _drawerButton(
                        icon: Get.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
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
                        icon: Icons.logout,
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
