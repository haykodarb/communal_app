import 'package:biblioteca/backend/login_backend.dart';
import 'package:biblioteca/routes.dart';
import 'package:get/get.dart';

class ScaffoldController extends GetxController {
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
