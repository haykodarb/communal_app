import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/messages/messages_controller.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  Widget _chatCard(MessagesController controller, Message message, Profile chatter) {
    final bool hightlightMessage = !message.is_read && message.receiver.id == UsersBackend.currentUserId;

    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => controller.goToSpecificChat(chatter),
          splashColor: Colors.transparent,
          child: Card(
            elevation: hightlightMessage ? 5 : 1,
            shadowColor:
                hightlightMessage ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
            color: hightlightMessage ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  CommonCircularAvatar(username: chatter.username, radius: 30),
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
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              DateFormat.MMMEd().format(
                                message.created_at.toLocal(),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 15),
                        SizedBox(
                          height: 25,
                          child: Text(
                            message.content,
                            style: TextStyle(
                              fontSize: 12,
                              overflow: TextOverflow.ellipsis,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                            ),
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
      },
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
            () => CommonLoadingBody(
              loading: controller.loading.value,
              child: Obx(
                () {
                  return ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: controller.distinctChats.length,
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 5,
                      );
                    },
                    itemBuilder: (context, index) {
                      final Message message = controller.distinctChats[index];
                      final Profile chatter =
                          message.sender.id == UsersBackend.currentUserId ? message.receiver : message.sender;

                      return _chatCard(controller, message, chatter);
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
