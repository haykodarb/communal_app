import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/message.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/messages/messages_specific/messages_specific_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessagesSpecificPage extends StatelessWidget {
  const MessagesSpecificPage({super.key});

  Widget _messageBubble(MessagesSpecificController controller, int index) {
    final Message message = controller.messages[index];

    final Message? nextMessage = index == 0 ? null : controller.messages[index - 1];

    final bool showTime = nextMessage == null || nextMessage.sender.id != message.sender.id;

    final bool isReceived = message.sender.id == controller.user.id;

    final bool isFirstMessage = index == 0;

    return Row(
      children: [
        Expanded(
          flex: isReceived ? 0 : 1,
          child: const SizedBox(),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: isReceived ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
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
                          color: isReceived ? Get.theme.colorScheme.secondary : Get.theme.colorScheme.primary,
                        ),
                        child: Text(
                          message.content,
                          style: TextStyle(
                            color: Get.theme.colorScheme.background,
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
                    color: Get.theme.colorScheme.onBackground.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
              Visibility(
                visible: isFirstMessage && message.is_read && message.sender.id == UsersBackend.getCurrentUserId(),
                child: Text(
                  'Seen',
                  textAlign: isReceived ? TextAlign.left : TextAlign.right,
                  style: TextStyle(
                    color: Get.theme.colorScheme.onBackground.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: isReceived ? 1 : 0,
          child: const SizedBox(),
        ),
      ],
    );
  }

  Widget _textInput(MessagesSpecificController controller) {
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
                    borderSide: BorderSide(color: Get.theme.colorScheme.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Get.theme.colorScheme.primary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(color: Get.theme.colorScheme.primary),
                  ),
                  hintText: 'Type something...',
                  hintStyle: TextStyle(
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            const VerticalDivider(width: 5),
            Container(
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Get.theme.colorScheme.primary,
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
                                color: Get.theme.colorScheme.onPrimary,
                              );
                            }

                            return Icon(
                              Icons.send,
                              color: Get.theme.colorScheme.onPrimary,
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
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: MessagesSpecificController(),
      builder: (MessagesSpecificController controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(controller.user.username),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CommonLoadingBody(
                    loading: controller.loading,
                    child: Obx(
                      () {
                        return ListView.separated(
                          reverse: true,
                          itemCount: controller.messages.length,
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                _textInput(controller),
              ],
            ),
          ),
        );
      },
    );
  }
}
