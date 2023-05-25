import 'package:biblioteca/presentation/common/scaffold_drawer/scaffold_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:biblioteca/presentation/dashboard/dashboard_controller.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: DashboardController(),
      builder: (DashboardController controller) {
        return Scaffold(
          drawer: const ScaffoldDrawer(),
          appBar: AppBar(),
          body: const SizedBox(),
        );
      },
    );
  }
}
