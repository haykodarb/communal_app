import 'package:biblioteca/presentation/community/community_specific/community_drawer/community_drawer_widget.dart';
import 'package:biblioteca/presentation/community/community_specific/community_specific_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificPage extends StatelessWidget {
  const CommunitySpecificPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(controller.community.name),
          ),
          endDrawer: CommunityDrawerWidget(
            community: controller.community,
          ),
          body: Column(),
        );
      },
    );
  }
}
