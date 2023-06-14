import 'dart:async';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class MessagesSpecificController extends GetxController {
  final Profile user = Get.arguments['user'];

  final Stream<Message> stream = Get.arguments['stream'];

  final TextEditingController textEditingController = TextEditingController();

  final RxString typedMessage = ''.obs;

  final RxList<Message> messages = <Message>[].obs;

  final RxBool sending = false.obs;
  final RxBool loading = false.obs;

  StreamSubscription? subscription;

  @override
  Future<void> onInit() async {
    super.onInit();

    loading.value = true;

    subscription ??= stream.listen(onMessageReceived);

    final BackendResponse response = await MessagesBackend.getMessagesWithUser(user);

    if (response.success) {
      messages.value = response.payload;
    }

    loading.value = false;
  }

  @override
  void onReady() {
    super.onReady();

    MessagesBackend.markMessagesWithUserAsRead(user);
  }

  @override
  Future<void> onClose() async {
    await subscription?.cancel();
    super.onClose();
  }

  void onMessageReceived(Message message) {
    final bool isCurrentChat = message.receiver.id == user.id && message.sender.id == UsersBackend.getCurrentUserId() ||
        message.sender.id == user.id && message.receiver.id == UsersBackend.getCurrentUserId();

    if (!isCurrentChat) return;

    final bool messageExists = messages.any((element) => element.id == message.id);

    if (messageExists) {
      messages.firstWhereOrNull((element) => element.id == message.id)?.is_read = true;
    } else {
      messages.insert(0, message);

      if (message.sender.id != UsersBackend.getCurrentUserId()) {
        MessagesBackend.markMessagesWithUserAsRead(user);
      }
    }

    messages.refresh();
  }

  void onTypedMessageChanged(String? value) {
    if (value != null) {
      typedMessage.value = value;
    }
  }

  Future<void> onMessageSubmit() async {
    if (typedMessage.value.isEmpty) return;

    sending.value = true;

    textEditingController.clear();

    await MessagesBackend.submitMessage(user, typedMessage.value);

    typedMessage.value = '';
    sending.value = false;
  }
}
