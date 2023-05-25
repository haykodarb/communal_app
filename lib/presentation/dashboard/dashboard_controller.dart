import 'package:biblioteca/backend/login_backend.dart';
import 'package:get/get.dart';
import 'package:biblioteca/models/book.dart';
import 'package:biblioteca/routes.dart';

class DashboardController extends GetxController {
  RxList<Book> loadedBooks = <Book>[].obs;

  // final Community community = Get.arguments["community"];

  Future<void> handleLogout() async {
    await LoginBackend.logout();
    Get.offAllNamed(RouteNames.startPage);
  }
}
