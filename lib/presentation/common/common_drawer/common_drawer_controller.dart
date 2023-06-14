import 'package:communal/backend/loans_backend.dart';
import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/messages_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';

class CommonDrawerController extends GetxController {
  final RxInt messageNotifications = 0.obs;
  final RxInt loanNotifications = 0.obs;
  final RxInt invitationsNotifications = 0.obs;

  final String username = UsersBackend.getCurrentUsername();

  void goToRoute(String routeName) {
    if (Get.currentRoute != routeName) {
      Get.offAllNamed(routeName);
    }
  }

  @override
  Future<void> onReady() async {
    super.onReady();

    loanNotifications.value = (await LoansBackend.getLoanCountWhere(LoansRequestType.userIsOwner)).payload;
    invitationsNotifications.value = (await UsersBackend.getInvitationsCountForUser()).payload;
    getUnreadChats();
  }

  Future<void> getUnreadChats() async {
    final BackendResponse response = await MessagesBackend.getDistinctChats();

    if (response.success) {
      final List<Message> messages = response.payload;

      int unreadCount = 0;

      for (int i = 0; i < messages.length; i++) {
        if (!messages[i].is_read && messages[i].receiver.id == UsersBackend.getCurrentUserId()) {
          unreadCount++;
        }
      }

      messageNotifications.value = unreadCount;
    }
  }

  void handleLogout() {
    LoginBackend.logout();
    Get.offAllNamed(RouteNames.startPage);
  }
}
