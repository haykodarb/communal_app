import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/message.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/messages/messages_specific/messages_specific_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class MessagesSpecificPage extends StatelessWidget {
  const MessagesSpecificPage({
    super.key,
    required this.userId,
  });

  final String userId;

  Widget _messageBubble(MessagesSpecificController controller, int index) {
    final Message message = controller.messages[index];

    final Message? nextMessage =
        index == 0 ? null : controller.messages[index - 1];

    bool showTime =
        nextMessage == null || nextMessage.sender.id != message.sender.id;

    if (nextMessage != null) {
      final int differenceMinutes =
          nextMessage.created_at.difference(message.created_at).inMinutes;

      if (differenceMinutes > 10) {
        showTime = true;
      }
    }

    final bool isReceived = message.sender.id == controller.userId;

    final bool isFirstMessage = index == 0;

    return Builder(
      builder: (context) {
        return Row(
          children: [
            Expanded(
              flex: isReceived ? 0 : 1,
              child: const SizedBox(),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: isReceived
                    ? CrossAxisAlignment.start
                    : CrossAxisAlignment.end,
                children: [
                  Container(
                    alignment: isReceived
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
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
                                  ? Theme.of(context)
                                      .colorScheme
                                      .secondary
                                      .withValues(alpha: 0.25)
                                  : Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.25),
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
                      DateFormat('dd MMM HH:mm', Get.locale!.languageCode)
                          .format(message.created_at.toLocal()),
                      textAlign: isReceived ? TextAlign.left : TextAlign.right,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isFirstMessage &&
                        message.is_read &&
                        message.sender.id == UsersBackend.currentUserId,
                    child: Text(
                      'Seen'.tr,
                      textAlign: isReceived ? TextAlign.left : TextAlign.right,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
      },
    );
  }

  Widget _textInput(MessagesSpecificController controller) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextFormField(
                    onChanged: controller.onTypedMessageChanged,
                    focusNode: FocusNode(
                      onKeyEvent: (node, event) {
                        if (kIsWeb &&
                            !HardwareKeyboard.instance.isShiftPressed &&
                            event.logicalKey.keyLabel == 'Enter') {
                          if (event is KeyDownEvent) {
                            controller.onMessageSubmit(context);
                          }
                          return KeyEventResult.handled;
                        }

                        return KeyEventResult.ignored;
                      },
                    ),
                    onFieldSubmitted: (_) =>
                        controller.onMessageSubmit(context),
                    controller: controller.textEditingController,
                    onTapOutside: (_) {},
                    style: const TextStyle(fontSize: 14),
                    minLines: kIsWeb ? 1 : null,
                    maxLines: kIsWeb ? 6 : null,
                    expands: !kIsWeb,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: kIsWeb ? 25 : 15,
                        horizontal: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15),
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15),
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.15),
                          width: 2,
                        ),
                      ),
                      hintText: 'Type something...'.tr,
                      hintStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(width: 5),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Obx(
                      () {
                        return InkWell(
                          onTap: controller.sending.value
                              ? null
                              : () => controller.onMessageSubmit(context),
                          enableFeedback: false,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Align(
                            alignment: Alignment.center,
                            child: Obx(
                              () {
                                if (controller.sending.value) {
                                  return SizedBox(
                                    width: 25,
                                    height: 25,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  );
                                }

                                return Icon(
                                  Icons.send_rounded,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  size: 30,
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
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
    print(userId);
    return GetBuilder(
      init: MessagesSpecificController(
        userId: userId,
      ),
      builder: (MessagesSpecificController controller) {
        return Scaffold(
          appBar: AppBar(
            title: Responsive.isMobile(context)
                ? Obx(
                    () {
                      return Text(controller.userProfile.value?.username ?? '');
                    },
                  )
                : null,
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Obx(
                    () => Visibility(
                      visible: controller.showLoadingMore.value,
                      child: Container(
                        color: Colors.transparent,
                        child: LoadingAnimationWidget.horizontalRotatingDots(
                          color: Theme.of(context).colorScheme.primary,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () => CommonLoadingBody(
                        loading: controller.loading.value,
                        child: Obx(
                          () {
                            if (controller.messages.isEmpty) {
                              return Center(
                                child: SizedBox(
                                  width: 350,
                                  child: Text(
                                    'Chat messages in Communal are still unencrypted, please refrain from sharing sensitive information here'
                                        .tr,
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              reverse: true,
                              itemCount: controller.messages.length,
                              controller: controller.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(
                                  right: 20, left: 20, top: 20, bottom: 90),
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
                ],
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _textInput(controller),
              ),
            ],
          ),
        );
      },
    );
  }
}
