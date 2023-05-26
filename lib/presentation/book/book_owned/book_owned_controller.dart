import 'package:biblioteca/models/book.dart';
import 'package:biblioteca/presentation/book/book_list_controller.dart';
import 'package:get/get.dart';

class BookOwnedController extends GetxController {
  final Book book = Get.arguments['book'];
  final BookListController myBooksController = Get.arguments['controller'];
}
