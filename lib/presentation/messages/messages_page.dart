import 'package:communal/presentation/messages/messages_controller.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: MessagesController(),
      builder: (MessagesController controller) {
        return Scaffold(
          drawer: CommonDrawerWidget(),
          appBar: AppBar(
            title: const Text('Messages'),
          ),
        );
      },
    );
  }
}
