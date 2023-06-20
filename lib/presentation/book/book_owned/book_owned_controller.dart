import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:get/get.dart';

class BookOwnedController extends GetxController {
  final Book book = Get.arguments['book'];
  final BookListController myBooksController = Get.arguments['controller'];

  final RxBool loading = false.obs;

  Loan? currentLoan;

  @override
  void onInit() {
    super.onInit();

    loadCurrentLoan();
  }

  Future<void> loadCurrentLoan() async {
    loading.value = true;

    final BackendResponse response = await LoansBackend.getCurrentLoanForBook(book);

    if (response.success) {
      currentLoan = response.payload;
    }

    loading.value = false;
  }
}
