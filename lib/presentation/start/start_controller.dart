import 'package:get/get.dart';
import 'package:biblioteca/routes.dart';

class StartController extends GetxController {
  void loginButtonCallback() {
    Get.toNamed(RouteNames.loginPage);
  }

  void registerButtonCallback() {
    Get.toNamed(RouteNames.registerPage);
  }
}
