import 'package:biblioteca/models/book.dart';
import 'package:biblioteca/presentation/mybooks/mybooks_controller.dart';
import 'package:get/get.dart';

class OwnedBookController extends GetxController {
  final Book book = Get.arguments['book'];
  final MyBooksController myBooksController = Get.arguments['controller'];
}
