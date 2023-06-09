import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
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
    book.loading.value = true;

    final BackendResponse response = await BooksBackend.deleteBook(book);

    if (response.success) {
      userBooks.remove(book);
      userBooks.refresh();
    } else {
      book.loading.value = false;

      Get.dialog(
        CommonAlertDialog(title: '${response.payload}'),
      );
    }
  }

  Future<void> reloadBooks() async {
    loading.value = true;
    final BackendResponse response = await BooksBackend.getAllBooksForUser();
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
