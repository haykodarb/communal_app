import 'dart:async';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesController extends GetxController {
  final RxList<Message> distinctChats = <Message>[].obs;

  final RxBool loading = false.obs;

  RealtimeChannel? subscription;

  StreamSubscription? streamSubscription;

  @override
  void onReady() {
    super.onReady();

    final Stream<RealtimeMessage> stream = RealtimeBackend.streamController.stream;

    streamSubscription = stream.listen(_realtimeListener);

    loadChats();
  }

  @override
  Future<void> onClose() async {
    await streamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _realtimeListener(RealtimeMessage realtimeMessage) async {
    if (realtimeMessage.table != 'messages') return;

    if (realtimeMessage.eventType != PostgresChangeEvent.insert &&
        realtimeMessage.eventType != PostgresChangeEvent.update) return;

    final Message unfetchedMessage = Message(
      id: realtimeMessage.new_row['id'],
      created_at: DateTime.parse(realtimeMessage.new_row['created_at']),
      sender: Profile(id: realtimeMessage.new_row['sender'], username: '', show_email: false),
      receiver: Profile(id: realtimeMessage.new_row['receiver'], username: '', show_email: false),
      content: realtimeMessage.new_row['content'],
      is_read: realtimeMessage.new_row['is_read'],
    );

    if (distinctChats.any((element) => element.id == unfetchedMessage.id)) {
      distinctChats.firstWhereOrNull((element) => element.id == unfetchedMessage.id)?.is_read =
          unfetchedMessage.is_read;
      distinctChats.refresh();
      return;
    }

    final BackendResponse response = await MessagesBackend.getMessageWithId(unfetchedMessage.id);

    if (!response.success) return;

    final Message message = response.payload;

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
