import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/loans/loans_borrowed/loans_borrowed_widget.dart';
import 'package:communal/presentation/loans/loans_completed/loans_completed_widget.dart';
import 'package:communal/presentation/loans/loans_controller.dart';
import 'package:communal/presentation/loans/loans_owned/loans_owned_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoansController(),
      builder: (LoansController controller) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Loans'),
              bottom: TabBar(
                indicatorColor: Get.theme.colorScheme.primary,
                tabs: const <Widget>[
                  Tab(text: 'Owned'),
                  Tab(text: 'Borrowed'),
                  Tab(text: 'Completed'),
                ],
              ),
            ),
            drawer: CommonDrawerWidget(),
            body: const TabBarView(
              children: [
                LoansOwnedWidget(),
                LoansBorrowedWidget(),
                LoansCompletedWidget(),
              ],
            ),
          ),
        );
      },
    );
  }
}
