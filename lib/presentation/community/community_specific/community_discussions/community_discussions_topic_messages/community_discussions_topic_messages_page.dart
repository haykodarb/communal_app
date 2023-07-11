import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/discussion.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_messages/community_discussions_topic_messages_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CommunityDiscussionsTopicMessagesPage extends StatelessWidget {
  const CommunityDiscussionsTopicMessagesPage({super.key});

  Widget _messageBubble(CommunityDiscussionsTopicMessagesController controller, int index) {
    final DiscussionMessage message = controller.messages[index];

    final bool isFirstMessage = index == 0;
    final bool isLastMessage = index == controller.messages.length - 1;

    final DiscussionMessage? previousMessage = isFirstMessage ? null : controller.messages[index - 1];

    final bool showTime = previousMessage == null || previousMessage.sender.id != message.sender.id;

    final DiscussionMessage? nextMessage = isLastMessage ? null : controller.messages[index + 1];

    final bool showAvatar = nextMessage == null || nextMessage.sender.id != message.sender.id;

    final bool isReceived = message.sender.id != UsersBackend.currentUserId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: isReceived ? 0 : 1,
          child: const SizedBox(),
        ),
        SizedBox(
          height: 50,
          width: 50,
          child: Visibility(
            visible: showAvatar && isReceived,
            child: CommonCircularAvatar(
              radius: 25,
              username: message.sender.username,
            ),
          ),
        ),
        const VerticalDivider(width: 5),
        Expanded(
          flex: 2,
          child: Builder(
            builder: (context) {
              return Column(
                crossAxisAlignment: isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Visibility(
                    visible: showAvatar && isReceived,
                    child: Text(message.sender.username),
                  ),
                  Visibility(
                    visible: showAvatar && isReceived,
                    child: const Divider(height: 5),
                  ),
                  Container(
                    alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(15),
                              color: isReceived
                                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.75)
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.75),
                            ),
                            child: Text(
                              message.content,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: showTime,
                    child: const Divider(height: 5),
                  ),
                  Visibility(
                    visible: showTime,
                    child: Text(
                      DateFormat.MMMd().add_Hm().format(message.created_at.toLocal()),
                      textAlign: isReceived ? TextAlign.left : TextAlign.right,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        Expanded(
          flex: isReceived ? 1 : 0,
          child: const SizedBox(),
        ),
      ],
    );
  }

  Widget _textInput(CommunityDiscussionsTopicMessagesController controller) {
    return Builder(
      builder: (context) {
        return SizedBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: controller.onTypedMessageChanged,
                    onEditingComplete: controller.onMessageSubmit,
                    controller: controller.textEditingController,
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                      ),
                      hintText: 'Type something...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 5),
                Container(
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  height: 60,
                  width: 60,
                  child: Obx(
                    () {
                      return InkWell(
                        onTap: controller.sending.value ? null : controller.onMessageSubmit,
                        enableFeedback: false,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: SizedBox.expand(
                          child: Center(
                            child: Obx(
                              () {
                                if (controller.sending.value) {
                                  return CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  );
                                }

                                return Icon(
                                  Icons.send,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                  size: 30,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityDiscussionsTopicMessagesController(),
      builder: (CommunityDiscussionsTopicMessagesController controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(controller.topic.name),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Obx(
                    () => CommonLoadingBody(
                      loading: controller.loading.value,
                      child: Obx(
                        () {
                          return ListView.separated(
                            reverse: true,
                            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                            itemCount: controller.messages.length,
                            separatorBuilder: (context, index) {
                              return const Divider(
                                height: 7.5,
                              );
                            },
                            itemBuilder: (context, index) {
                              return _messageBubble(controller, index);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                _textInput(controller),
              ],
            ),
          ),
        );
      },
    );
  }
}
