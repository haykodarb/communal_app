import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:get/get.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:flutter/material.dart';

class ProfileOtherController extends GetxController {
  static const int pageSize = 20;

  ProfileOtherController({
    required this.userId,
  });

  final String userId;

  final Rx<Profile> profile = Profile.empty().obs;

  final CommonListViewController<Loan> reviewListController = CommonListViewController(pageSize: pageSize);
  final CommonListViewController<Book> bookListController = CommonListViewController(pageSize: pageSize);

  final RxBool loadingProfile = true.obs;

  final ScrollController scrollController = ScrollController();
  final RxInt currentTabIndex = 0.obs;

  void onTabTapped(int value) {
    if (value != currentTabIndex.value) {
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
  Future<void> onInit() async {
    super.onInit();

    loadingProfile.value = true;

    final BackendResponse response = await UsersBackend.getUserProfile(userId);

    if (response.success) {
      profile.value = response.payload;
    }

    loadingProfile.value = false;
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
      userToQuery: userId,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }

  Future<List<Loan>> loadReviews(int pageKey) async {
    final BackendResponse response = await LoansBackend.getBooksReviewedByUser(
      userId: userId,
      pageSize: pageSize,
      pageKey: pageKey,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }
}
