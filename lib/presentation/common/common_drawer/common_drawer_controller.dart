import 'package:communal/backend/loans_backend.dart';
import 'package:communal/backend/login_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';

class CommonDrawerController extends GetxController {
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
  }

  void handleLogout() {
    LoginBackend.logout();
    Get.offAllNamed(RouteNames.startPage);
  }
}
