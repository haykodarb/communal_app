import 'dart:async';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class MessagesSpecificController extends GetxController {
  final Profile user = Get.arguments['user'];

  final TextEditingController textEditingController = TextEditingController();

  final RxString typedMessage = ''.obs;

  final RxList<Message> messages = <Message>[].obs;

  final RxBool sending = false.obs;
  final RxBool loading = false.obs;

  final ScrollController scrollController = ScrollController();

  bool loadingMore = false;

  int currentIndex = 0;

  StreamSubscription? streamSubscription;

  @override
  Future<void> onInit() async {
    super.onInit();

    loading.value = true;

    final Stream<Message> stream = Get.find<CommonDrawerController>().messagesStreamController.stream;

    streamSubscription = stream.listen(messageChangeHandler);

    final BackendResponse response = await MessagesBackend.getMessagesWithUser(user, currentIndex);

    currentIndex++;

    scrollController.addListener(scrollControllerListener);

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
    await streamSubscription?.cancel();

    super.onClose();
  }

  Future<void> scrollControllerListener() async {
    if (scrollController.position.pixels > scrollController.position.maxScrollExtent * 0.9) {
      if (loadingMore) return;

      loadingMore = true;

      final bool noMoreMessages = await getMoreMessages();

      if (noMoreMessages) {
        scrollController.removeListener(scrollControllerListener);
      }

      Future.delayed(
        const Duration(milliseconds: 500),
        () => loadingMore = false,
      );
    }
  }

  Future<bool> getMoreMessages() async {
    final BackendResponse response = await MessagesBackend.getMessagesWithUser(user, currentIndex);

    if (response.success) {
      final List<Message> newMessages = response.payload;

      messages.addAll(newMessages);
      currentIndex++;

      return newMessages.isEmpty;
    }

    return false;
  }

  void messageChangeHandler(Message message) {
    final bool isCurrentChat = message.receiver.id == user.id && message.sender.id == UsersBackend.getCurrentUserId() ||
        message.sender.id == user.id && message.receiver.id == UsersBackend.getCurrentUserId();

    if (!isCurrentChat) return;

    final bool messageExists = messages.any((element) => element.id == message.id);

    if (messageExists) {
      messages.firstWhereOrNull((element) => element.id == message.id)?.is_read = true;
    } else {
      if (message.sender.id != UsersBackend.getCurrentUserId()) {
        messages.insert(0, message);
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

    final String randomID = UniqueKey().toString();

    final Message newMessage = Message(
      id: randomID,
      created_at: DateTime.now(),
      sender: Profile(
        id: UsersBackend.getCurrentUserId(),
        username: UsersBackend.getCurrentUsername(),
      ),
      receiver: user,
      content: typedMessage.value,
      is_read: false,
    );

    messages.insert(0, newMessage);

    final BackendResponse response = await MessagesBackend.submitMessage(user, typedMessage.value);

    if (response.success) {
      final int index = messages.indexWhere((element) => element.id == randomID);

      messages[index] = response.payload;
    } else {
      messages.removeWhere((element) => element.id == randomID);

      Get.dialog(const CommonAlertDialog(title: 'Could not send message, likely network error.'));
    }

    typedMessage.value = '';
    sending.value = false;
  }
}
