import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/messages/messages_controller.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  Widget _chatCard(Message message, Profile chatter) {
    final bool hightlightMessage = message.is_read || message.sender.id == UsersBackend.getCurrentUserId();

    return InkWell(
      onTap: () {
        Get.toNamed(
          RouteNames.messagesSpecificPage,
          arguments: {'user': chatter},
        );
      },
      splashColor: Colors.transparent,
      child: Card(
        elevation: hightlightMessage ? 1 : 5,
        shadowColor: hightlightMessage ? Get.theme.colorScheme.secondary : Get.theme.colorScheme.primary,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                minRadius: 20,
                maxRadius: 30,
                backgroundColor: hightlightMessage ? Get.theme.colorScheme.secondary : Get.theme.colorScheme.primary,
                child: Text(
                  chatter.username.substring(0, 2).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const VerticalDivider(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          chatter.username,
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          DateFormat.MMMEd().format(
                            message.created_at.toLocal(),
                          ),
                          style: TextStyle(
                            fontSize: 14,
                            color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Get.theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
          body: Obx(
            () {
              return CommonLoadingBody(
                isLoading: controller.loading.value,
                child: Obx(
                  () {
                    return ListView.separated(
                      padding: const EdgeInsets.all(10),
                      itemCount: controller.distinctChats.length,
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemBuilder: (context, index) {
                        final Message message = controller.distinctChats[index];
                        final Profile chatter =
                            message.sender.id == UsersBackend.getCurrentUserId() ? message.receiver : message.sender;

                        return _chatCard(message, chatter);
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
