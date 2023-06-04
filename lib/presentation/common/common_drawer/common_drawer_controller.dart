import 'package:communal/backend/login_backend.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';

class CommonDrawerController extends GetxController {
  void goToRoute(String routeName) {
    if (Get.currentRoute != routeName) {
      Get.offAllNamed(routeName);
    }
  }

  void handleLogout() {
    LoginBackend.logout();
    Get.offAllNamed(RouteNames.startPage);
  }
}
