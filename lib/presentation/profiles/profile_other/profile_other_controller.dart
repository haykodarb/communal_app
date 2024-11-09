import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';

class ProfileOtherController extends GetxController {
  ProfileOtherController({
    required this.userId,
  });

  final String userId;

  final Rx<Profile> profile = Profile.empty().obs;

  RxBool loadingProfile = true.obs;
  RxBool loadingBooks = false.obs;
  RxBool loadingReviews = false.obs;

  final RxList<Book> userBooks = <Book>[].obs;
  final RxList<Loan> userReviews = <Loan>[].obs;
  final ScrollController scrollController = ScrollController();
  final RxInt currentTabIndex = 0.obs;

  final GlobalKey<ExtendedNestedScrollViewState> nestedScrollViewKey =
      GlobalKey<ExtendedNestedScrollViewState>();

  void onTabTapped(int value) {
    if (value != currentTabIndex.value) {
      nestedScrollViewKey.currentState?.outerController.jumpTo(0);
    }
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

    loadBooks();
    loadReviews();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadBooks() async {
    loadingBooks.value = true;
    final BackendResponse response =
        await BooksBackend.getAllBooksForUser(userToQuery: profile.value.id);
    loadingBooks.value = false;

    if (response.success) {
      userBooks.value = response.payload;
      userBooks.refresh();
    }
  }

  Future<void> loadReviews() async {
    loadingReviews.value = true;
    final BackendResponse response =
        await LoansBackend.getBooksReviewedByUser(profile.value);
    loadingReviews.value = false;

    if (response.success) {
      userReviews.value = response.payload;
      userReviews.refresh();
    }
  }
}
