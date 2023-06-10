import 'package:communal/models/message.dart';
import 'package:communal/presentation/messages/messages_specific/messages_specific_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class MessagesSpecificPage extends StatelessWidget {
  const MessagesSpecificPage({super.key});

  Widget _textInput(MessagesSpecificController controller) {
    return SizedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: controller.onTypedMessageChanged,
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
                  suffixIcon: IconButton(
                    padding: const EdgeInsets.only(right: 10),
                    onPressed: controller.onMessageSubmit,
                    icon: Icon(
                      Icons.send,
                      color: Get.theme.colorScheme.primary,
                    ),
                    iconSize: 30,
                  ),
                ),
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
                  child: Obx(() {
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
                        final Message message = controller.messages[controller.messages.length - index - 1];
                        final bool isReceived = message.sender == controller.user.id;

                        return Row(
                          children: [
                            Expanded(
                              flex: isReceived ? 0 : 2,
                              child: const SizedBox(),
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(15),
                                  color: isReceived ? Get.theme.colorScheme.secondary : Get.theme.colorScheme.primary,
                                ),
                                alignment: isReceived ? Alignment.centerLeft : Alignment.centerRight,
                                child: Text(
                                  message.content,
                                  style: TextStyle(
                                    color: Get.theme.colorScheme.background,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: isReceived ? 2 : 0,
                              child: const SizedBox(),
                            ),
                          ],
                        );
                      },
                    );
                  }),
                ),
                _textInput(controller),
                const Divider(),
              ],
            ),
          ),
        );
      },
    );
  }
}
