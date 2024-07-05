import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_page.dart';
import 'package:communal/presentation/community/community_specific/community_books/community_books_page.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_page.dart';
import 'package:communal/presentation/community/community_specific/community_settings/community_settings_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:communal/presentation/community/community_specific/community_tools/community_tools_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificPage extends StatelessWidget {
  const CommunitySpecificPage({super.key});

  static const List<Widget> _pages = <Widget>[
    CommunityBooksPage(),
    CommunityToolsPage(),
    CommunityDiscussionsPage(),
    CommunityMembersPage(),
    CommunitySettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificController(),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: Text(controller.community.name),
          ),
          extendBody: true,
          bottomNavigationBar: Theme(
            data: Theme.of(context).copyWith(
              highlightColor: Colors.transparent,
              dialogBackgroundColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),

            child: SafeArea(
              child: Container(
                color: Colors.transparent,
                margin: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
                height: 70,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(50),
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                        spreadRadius: 2,
                        color: Theme.of(context).colorScheme.shadow,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: double.maxFinite,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Atlas.book,
                              color: Theme.of(context).colorScheme.surfaceContainer,
                              size: 24,
                            ),
                            const VerticalDivider(width: 5),
                            Text(
                              'Books',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surfaceContainer,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Icon(
                          Icons.handyman_outlined,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: Icon(
                          Atlas.chats,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Expanded(
                        child: Icon(
                          Atlas.users,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // child: Obx(
            //   () => BottomNavigationBar(
            //     currentIndex: controller.selectedIndex.value,
            //     onTap: controller.onBottomNavBarIndexChanged,
            //     enableFeedback: false,
            //     fixedColor: Theme.of(context).colorScheme.primary,
            //     backgroundColor: Theme.of(context).colorScheme.surface,
            //     iconSize: 22,
            //     items: const <BottomNavigationBarItem>[
            //       BottomNavigationBarItem(
            //         icon: Icon(Atlas.library),
            //         label: 'Books',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(
            //           Icons.handyman_outlined,
            //           opticalSize: 48,
            //           size: 25,
            //         ),
            //         label: 'Tools',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(Atlas.chats),
            //         label: 'Discuss',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(Atlas.users),
            //         label: 'Members',
            //       ),
            //       BottomNavigationBarItem(
            //         icon: Icon(Atlas.gear),
            //         label: 'Settings',
            //       ),
            //     ],
            //   ),
            // ),
          ),
          body: Obx(() => _pages[controller.selectedIndex.value]),
        );
      },
    );
  }
}
