import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_controller.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileOwnController extends GetxController {
  static const int pageSize = 20;
  RxBool loadingBooks = false.obs;

  final ScrollController scrollController = ScrollController();

  final RxInt currentTabIndex = 0.obs;

  final CommonListViewController<Loan> reviewListController =
      CommonListViewController(pageSize: pageSize);
  final CommonListViewController<Book> bookListController =
      CommonListViewController(pageSize: pageSize);

  final CommonDrawerController commonDrawerController = Get.find();

  void onTabTapped(int value) {
    if (value != currentTabIndex.value && scrollController.hasClients) {
      scrollController.jumpTo(0);
    }

    currentTabIndex.value = value;
  }

  @override
  void onReady() {
    super.onReady();
    reviewListController.registerNewPageCallback(loadReviews);
    bookListController.registerNewPageCallback(loadBooks);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<List<Book>> loadBooks(int pageKey) async {
    final BackendResponse response = await BooksBackend.getAllBooksForUser(
      pageSize: pageSize,
      pageKey: pageKey,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }

  void deleteBook(String id) {
    bookListController.itemList.removeWhere((element) => element.id != id);
    bookListController.itemList.refresh();
    bookListController.pageKey--;
  }

  Future<List<Loan>> loadReviews(int pageKey) async {
    final BackendResponse response = await LoansBackend.getBooksReviewedByUser(
      pageKey: pageKey,
      pageSize: pageSize,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }
}
