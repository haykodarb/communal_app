import 'dart:async';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/realtime_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/models/realtime_message.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesSpecificController extends GetxController {
  MessagesSpecificController({
    required this.userId,
    this.receivedProfile,
  });

  final String userId;
  Profile? receivedProfile;
  final Rxn<Profile> userProfile = Rxn<Profile>();

  final TextEditingController textEditingController = TextEditingController();

  final RxString typedMessage = ''.obs;

  final RxList<Message> messages = <Message>[].obs;

  final RxBool sending = false.obs;
  final RxBool loading = false.obs;
  final RxBool showLoadingMore = false.obs;
  bool loadingMore = false;

  final ScrollController scrollController = ScrollController();

  Timer? debounceTimer;

  int currentIndex = 0;

  StreamSubscription? streamSubscription;

  @override
  Future<void> onInit() async {
    loading.value = true;

    if (receivedProfile == null) {
      final BackendResponse profileResponse =
          await UsersBackend.getUserProfile(userId);

      if (profileResponse.success) {
        userProfile.value = profileResponse.payload;
      }
    } else {
      userProfile.value = receivedProfile;
    }

    final Stream<RealtimeMessage> stream =
        RealtimeBackend.streamController.stream;

    streamSubscription = stream.listen(messageChangeHandler);

    final BackendResponse messagesResponse =
        await MessagesBackend.getMessagesWithUser(userId, currentIndex);

    currentIndex++;

    scrollController.addListener(scrollControllerListener);

    if (messagesResponse.success) {
      messages.value = messagesResponse.payload;
    }

    loading.value = false;
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();

    MessagesBackend.markMessagesWithUserAsRead(userId);
  }

  @override
  Future<void> onClose() async {
    await streamSubscription?.cancel();

    super.onClose();
  }

  Future<void> scrollControllerListener() async {
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent * 0.9) {
      if (loadingMore) {
        return;
      }

      showLoadingMore.value = true;
      loadingMore = true;

      final bool noMoreMessages = await getMoreMessages();

      if (noMoreMessages) {
        scrollController.removeListener(scrollControllerListener);
      }

      showLoadingMore.value = false;

      debounceTimer = Timer(
        const Duration(milliseconds: 500),
        () {
          loadingMore = false;
        },
      );
    }
  }

  Future<bool> getMoreMessages() async {
    final BackendResponse response =
        await MessagesBackend.getMessagesWithUser(userId, currentIndex);

    if (response.success) {
      final List<Message> newMessages = response.payload;

      messages.addAll(newMessages);
      currentIndex++;

      return newMessages.isEmpty;
    }

    return false;
  }

  void messageChangeHandler(RealtimeMessage realtimeMessage) {
    if (realtimeMessage.table != 'messages') return;

    if (realtimeMessage.eventType != PostgresChangeEvent.insert &&
        realtimeMessage.eventType != PostgresChangeEvent.update) return;

    final Message message = Message(
      id: realtimeMessage.new_row['id'],
      created_at: DateTime.parse(realtimeMessage.new_row['created_at']),
      sender: Profile(
          id: realtimeMessage.new_row['sender'],
          username: '',
          show_email: false),
      receiver: Profile(
          id: realtimeMessage.new_row['receiver'],
          username: '',
          show_email: false),
      content: realtimeMessage.new_row['content'],
      is_read: realtimeMessage.new_row['is_read'],
    );

    final bool isCurrentChat =
        message.receiver.id == userId && message.sender.isCurrentUser ||
            message.sender.id == userId && message.receiver.isCurrentUser;

    if (!isCurrentChat) return;

    final bool messageExists =
        messages.any((element) => element.id == message.id);

    if (messageExists) {
      messages
          .firstWhereOrNull((element) => element.id == message.id)
          ?.is_read = message.is_read;
    } else if (!message.sender.isCurrentUser) {
      messages.insert(0, message);
      MessagesBackend.markMessagesWithUserAsRead(userId);
    }

    messages.refresh();
  }

  void onTypedMessageChanged(String? value) {
    if (value != null) {
      typedMessage.value = value;
    }
  }

  Future<void> onMessageSubmit(BuildContext context) async {
    if (typedMessage.value.isEmpty) return;

    sending.value = true;

    textEditingController.clear();

    final String randomID = UniqueKey().toString();

    final Message newMessage = Message(
      id: randomID,
      created_at: DateTime.now(),
      sender: Profile(
        id: UsersBackend.currentUserId,
        username: UsersBackend.getCurrentUsername(),
        show_email: false,
      ),
      receiver: userProfile.value!,
      content: typedMessage.value,
      is_read: false,
    );

    messages.insert(0, newMessage);

    final BackendResponse response =
        await MessagesBackend.submitMessage(userId, typedMessage.value);

    if (response.success) {
      final int index =
          messages.indexWhere((element) => element.id == randomID);

      messages[index] = response.payload;
    } else {
      messages.removeWhere((element) => element.id == randomID);
      if (context.mounted) {
        const CommonAlertDialog(
          title: 'Could not send message, likely network error.',
        ).open(context);
      }
    }

    typedMessage.value = '';
    sending.value = false;
  }
}
