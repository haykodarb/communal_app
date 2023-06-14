import 'package:communal/backend/messages_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesSpecificController extends GetxController {
  final Profile user = Get.arguments['user'];

  final TextEditingController textEditingController = TextEditingController();

  final RxString typedMessage = ''.obs;

  final RxList<Message> messages = <Message>[].obs;

  final RxBool sending = false.obs;
  final RxBool loading = false.obs;

  RealtimeChannel? subscription;

  @override
  Future<void> onInit() async {
    super.onInit();

    loading.value = true;

    subscription ??= MessagesBackend.subscribeToMessagesWithUser(user, onNewMessageReceived);

    subscription!.subscribe();

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
  void onClose() {
    subscription?.unsubscribe();

    super.onClose();
  }

  void onNewMessageReceived(Message message) {
    messages.add(message);
  }

  void onTypedMessageChanged(String? value) {
    if (value != null) {
      typedMessage.value = value;
    }
  }

  Future<void> onMessageSubmit() async {
    if (typedMessage.value.isEmpty) return;

    sending.value = true;
    final BackendResponse response = await MessagesBackend.submitMessage(user, typedMessage.value);

    if (response.success) {
      textEditingController.clear();
      typedMessage.value = '';
    }
    sending.value = false;
  }
}
