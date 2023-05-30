import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';

class BookListController extends GetxController {
  final RxList<Book> userBooks = <Book>[].obs;
  final RxBool loading = true.obs;

  @override
  Future<void> onReady() async {
    super.onReady();

    await reloadBooks();
  }

  Future<void> deleteBook(Book book) async {
    book.deleting.value = true;

    await BooksBackend.deleteBook(book);

    userBooks.remove(book);
    userBooks.refresh();
  }

  Future<void> reloadBooks() async {
    loading.value = true;
    final BackendResponse response = await BooksBackend.getAllBooks();
    loading.value = false;

    if (response.success) {
      userBooks.value = response.payload;
      userBooks.refresh();
    }
  }

  Future<void> goToAddBookPage() async {
    final dynamic result = await Get.toNamed(RouteNames.bookCreatePage);

    if (result != null) {
      userBooks.add(result);
      userBooks.refresh();
    }
  }
}
