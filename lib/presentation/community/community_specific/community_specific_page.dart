import 'package:communal/presentation/community/community_specific/community_home/community_home_page.dart';
import 'package:communal/presentation/community/community_specific/community_members/community_members_page.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificPage extends StatelessWidget {
  const CommunitySpecificPage({super.key});

  static const List<Widget> _pages = <Widget>[
    CommunityHomePage(),
    CommunityMembersPage(),
    CommunityMembersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(controller.community.name),
          ),
          bottomNavigationBar: Obx(
            () => BottomNavigationBar(
              currentIndex: controller.selectedIndex.value,
              onTap: controller.onBottomNavBarIndexChanged,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
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
