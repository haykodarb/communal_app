import 'package:biblioteca/presentation/common/scaffold_drawer/scaffold_drawer.dart';
import 'package:biblioteca/presentation/communities/communities_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitiesPage extends StatelessWidget {
  CommunitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitiesController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Communities'),
          ),
          drawer: const ScaffoldDrawer(),
          body: const Text('Communities'),
        );
      },
    );
  }
}
