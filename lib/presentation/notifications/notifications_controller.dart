import 'package:communal/backend/notifications_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final RxList<CustomNotification> notifications = <CustomNotification>[].obs;

  @override
  Future<void> onInit() async {
    final BackendResponse response = await NotificationsBackend.getNotifications();
    if (response.success) {
      notifications.value = response.payload;
      notifications.refresh();
    }
    super.onInit();
  }
}
