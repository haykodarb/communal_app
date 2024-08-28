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
          height: 40,
          width: 40,
          child: Visibility(
            visible: showAvatar && isReceived,
            child: CommonCircularAvatar(
              radius: 20,
              clickable: true,
              profile: message.sender,
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
                                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.25)
                                  : Theme.of(context).colorScheme.primary.withOpacity(0.25),
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
                      DateFormat.MMMd(Get.locale?.languageCode).add_Hm().format(message.created_at.toLocal()),
                      textAlign: isReceived ? TextAlign.left : TextAlign.right,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        return Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  onChanged: controller.onTypedMessageChanged,
                  onEditingComplete: controller.onMessageSubmit,
                  controller: controller.textEditingController,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  minLines: 1,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                        width: 2,
                      ),
                    ),
                    hintText: 'Type something...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                                Icons.send_rounded,
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
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(controller.topic.name),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                Obx(
                  () => CommonLoadingBody(
                    loading: controller.loading.value,
                    child: Obx(
                      () {
                        return ListView.separated(
                          reverse: true,
                          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 90),
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
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _textInput(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
