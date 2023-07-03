import 'dart:async';

import 'package:communal/backend/messages_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesController extends GetxController {
  final RxList<Message> distinctChats = <Message>[].obs;

  final RxBool loading = false.obs;

  RealtimeChannel? subscription;

  StreamSubscription? streamSubscription;

  @override
  void onInit() {
    super.onInit();

    final Stream<Message> stream = Get.find<CommonDrawerController>().messagesStreamController.stream;

    streamSubscription = stream.listen(messagesChangeHandler);

    loadChats();
  }

  @override
  Future<void> onClose() async {
    await streamSubscription?.cancel();
    super.onClose();
  }

  Future<void> messagesChangeHandler(Message message) async {
    if (distinctChats.any((element) => element.id == message.id)) {
      distinctChats.firstWhereOrNull((element) => element.id == message.id)?.is_read = true;
      distinctChats.refresh();
      return;
    }

    final int indexOfExisting = distinctChats.indexWhere(
      (element) =>
          (element.receiver.id == message.receiver.id && element.sender.id == message.sender.id) ||
          (element.sender.id == message.receiver.id && element.receiver.id == message.sender.id),
    );

    if (indexOfExisting >= 0) {
      distinctChats[indexOfExisting] = message;
    } else {
      distinctChats.insert(0, message);
    }

    distinctChats.refresh();
  }

  Future<void> goToSpecificChat(Profile chatter) async {
    Get.toNamed(
      RouteNames.messagesSpecificPage,
      arguments: {
        'user': chatter,
      },
    );
  }

  Future<void> loadChats() async {
    loading.value = true;

    final BackendResponse response = await MessagesBackend.getDistinctChats();

    if (response.success) {
      distinctChats.value = response.payload;
    }

    loading.value = false;
  }
}
