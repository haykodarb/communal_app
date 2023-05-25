import 'package:biblioteca/backend/login_backend.dart';
import 'package:biblioteca/routes.dart';
import 'package:get/get.dart';

class ScaffoldController extends GetxController {
  void goToMyBooks() {
    Get.offAllNamed(RouteNames.myBooksPage);
  }

  void handleLogout() {
    LoginBackend.logout();
    Get.offAllNamed(RouteNames.startPage);
  }
}
