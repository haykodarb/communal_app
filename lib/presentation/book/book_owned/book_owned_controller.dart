import 'package:communal/models/book.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:get/get.dart';

class BookOwnedController extends GetxController {
  final Book book = Get.arguments['book'];
  final BookListController myBooksController = Get.arguments['controller'];
}
