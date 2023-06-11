import 'package:communal/backend/messages_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:get/get.dart';

class MessagesController extends GetxController {
  final RxList<Message> distinctChats = <Message>[].obs;

  final RxBool loading = false.obs;

  @override
  void onInit() {
    super.onInit();

    loadChats();
    // MessagesBackend.getDistinctChats();
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
