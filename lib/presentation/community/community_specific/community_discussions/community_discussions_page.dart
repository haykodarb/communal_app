import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityDiscussionsPage extends StatelessWidget {
  const CommunityDiscussionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityDiscussionsController(),
      builder: (controller) {
        return const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: Text(
                'Community Discussions Page currently in development.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        );
      },
    );
  }
}
