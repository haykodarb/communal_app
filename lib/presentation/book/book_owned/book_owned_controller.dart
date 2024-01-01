import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';

class BookOwnedController extends GetxController {
  final Rx<Book> book = Book.empty().obs;

  final BookListController myBooksController = Get.arguments['controller'];

  final RxBool loading = false.obs;

  Loan? currentLoan;

  @override
  void onInit() {
    super.onInit();

    book.value = Get.arguments['book'];
    book.refresh();

    loadCurrentLoan();
  }

  Future<void> deleteBook() async {
    final bool deleteConfirm = await Get.dialog<bool>(
          CommonConfirmationDialog(
            title: 'Delete book?',
            confirmCallback: () => Get.back<bool>(result: true),
            cancelCallback: () => Get.back<bool>(result: false),
          ),
        ) ??
        false;

    if (deleteConfirm) {
      myBooksController.deleteBook(book.value);
      Get.back();
    }
  }

  Future<void> loadCurrentLoan() async {
    loading.value = true;

    final BackendResponse response = await LoansBackend.getCurrentLoanForBook(book.value);

    if (response.success) {
      currentLoan = response.payload;
    }

    loading.value = false;
  }

  Future<void> editBook() async {
    final Book? response = await Get.toNamed<dynamic>(
      RouteNames.bookEditPage,
      arguments: {
        'book': book.value,
      },
    );

    if (response != null) {
      book.value = response;
      book.refresh();
    }
  }
}
