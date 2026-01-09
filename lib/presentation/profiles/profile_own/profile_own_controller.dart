import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/presentation/profiles/common/profile_common_controller.dart';
import 'package:get/get.dart';

class ProfileOwnController extends ProfileCommonController {
  RxBool loadingBooks = false.obs;

  final CommonDrawerController commonDrawerController = Get.find();

  @override
  Future<List<Book>> loadBooks(int pageKey) async {
    final BackendResponse response = await BooksBackend.getAllBooksForUser(
      pageSize: ProfileCommonController.pageSize,
      pageKey: pageKey,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }

  void deleteBook(String id) {
    bookListController.itemList.removeWhere((element) => element.id == id);
    bookListController.itemList.refresh();
    bookListController.pageKey--;
  }

  @override
  Future<List<Loan>> loadReviews(int pageKey) async {
    final BackendResponse response = await LoansBackend.getBooksReviewedByUser(
      pageKey: pageKey,
      pageSize: ProfileCommonController.pageSize,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }
}
