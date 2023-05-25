import 'package:biblioteca/presentation/common/scaffold_drawer/scaffold_drawer.dart';
import 'package:biblioteca/presentation/communities/communities_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitiesPage extends StatelessWidget {
  const CommunitiesPage({super.key});

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
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Communities'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: controller.goToCreateCommunity,
                          child: const Text('New'),
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Invites'),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
