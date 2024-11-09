import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_responsive_page.dart';
import 'package:communal/presentation/messages/messages_controller.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/responsive.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  Widget _chatCard(MessagesController controller, int index) {
    final Message staticMessage = controller.distinctChats[index].value;

    final Profile staticChatter = staticMessage.sender.isCurrentUser
        ? staticMessage.receiver
        : staticMessage.sender;

    return Builder(
      builder: (context) {
        return InkWell(
          onTap: () => controller.goToSpecificChat(staticChatter, context),
          onLongPress: () => controller.deleteChatsWithUsers(staticChatter),
          splashColor: Colors.transparent,
          child: Card(
            margin: EdgeInsets.zero,
            child: Container(
              height: 90,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CommonCircularAvatar(
                      profile: staticChatter, radius: 25, clickable: true),
                  const VerticalDivider(width: 20),
                  Obx(
                    () {
                      bool hightlightMessage = false;

                      final Message message =
                          controller.distinctChats[index].value;

                      final Profile chatter = message.sender.isCurrentUser
                          ? message.receiver
                          : message.sender;

                      if (message.unread_messages != null) {
                        hightlightMessage = message.unread_messages! > 0;
                      }

                      return Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    chatter.username,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      height: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                const VerticalDivider(width: 10),
                                Text(
                                  DateFormat.MMMEd().format(
                                    message.created_at.toLocal(),
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hightlightMessage
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    fontWeight: FontWeight.w400,
                                    fontStyle: FontStyle.italic,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    message.content,
                                    style: TextStyle(
                                      fontSize: 12,
                                      overflow: TextOverflow.ellipsis,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const VerticalDivider(width: 10),
                                Visibility(
                                  visible: hightlightMessage,
                                  child: Container(
                                    height: 25,
                                    width: 25,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 5),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        message.unread_messages.toString(),
                                        style: TextStyle(
                                          fontSize: 12,
                                          overflow: TextOverflow.ellipsis,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                          fontWeight: FontWeight.w600,
                                          height: 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
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
        return CommonResponsivePage(
          child: Scaffold(
            drawer: Responsive.isMobile(context) ? CommonDrawerWidget() : null,
            appBar: AppBar(
              title: const Text(
                'Messages',
              ),
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
                        return const Divider(height: 5);
                      },
                      itemBuilder: (context, index) {
                        return CommonKeepaliveWrapper(
                          child: _chatCard(controller, index),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
