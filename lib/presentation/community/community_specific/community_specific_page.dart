import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_page.dart';
import 'package:communal/presentation/community/community_specific/community_home/community_home_page.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_page.dart';
import 'package:communal/presentation/community/community_specific/community_settings/community_settings_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificPage extends StatelessWidget {
  const CommunitySpecificPage({super.key});

  static const List<Widget> _pages = <Widget>[
    CommunityHomePage(),
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
          bottomNavigationBar: Obx(
            () => BottomNavigationBar(
              currentIndex: controller.selectedIndex.value,
              onTap: controller.onBottomNavBarIndexChanged,
              showUnselectedLabels: false,
              elevation: 10,
              useLegacyColorScheme: false,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: 'Discussions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: 'Members',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
            ),
          ),
          body: Obx(() => _pages[controller.selectedIndex.value]),
        );
      },
    );
  }
}
