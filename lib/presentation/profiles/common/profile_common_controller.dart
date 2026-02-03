import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

abstract class ProfileCommonController extends GetxController {
  static const int pageSize = 20;

  final ScrollController scrollController = ScrollController();
  final RxInt currentTabIndex = 0.obs;

  final CommonListViewController<Loan> reviewListController =
      CommonListViewController(pageSize: pageSize);
  final CommonListViewController<Book> bookListController =
      CommonListViewController(pageSize: pageSize);

  void onTabTapped(int value) {
    if (value != currentTabIndex.value && scrollController.hasClients) {
      scrollController.jumpTo(0);
    }

    currentTabIndex.value = value;
  }

  @override
  void onInit() {
    super.onInit();
    reviewListController.registerNewPageCallback(loadReviews);
    bookListController.registerNewPageCallback(loadBooks);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<List<Book>> loadBooks(int pageKey);
  Future<List<Loan>> loadReviews(int pageKey);
}
