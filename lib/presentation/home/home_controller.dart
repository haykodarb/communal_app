import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/loans_backend.dart';
import 'package:communal/backend/reviews_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/review.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  /// How many loans and reviews to show before "See all".
  static const int loansPreview = 2;
  static const int reviewsPreview = 2;
  static const int networkPageSize = 20;

  final ScrollController scrollController = ScrollController();

  final RxList<Loan> activeLoans = <Loan>[].obs;
  final RxList<Review> reviews = <Review>[].obs;

  final CommonListViewController<Book> networkListController =
      CommonListViewController(pageSize: networkPageSize);

  @override
  void onInit() {
    super.onInit();
    networkListController.registerNewPageCallback(loadNetworkBooks);
    loadActiveLoans();
    loadReviews();
  }

  /// Books out right now, in both directions.
  Future<void> loadActiveLoans() async {
    final LoansFilterParams params = LoansFilterParams()
      ..allStatus = false
      ..accepted = true;

    final BackendResponse response =
        await LoansBackend.getLoansForUser(params, 0, loansPreview);

    if (response.success) {
      activeLoans.value = response.payload;
    }
  }

  Future<void> loadReviews() async {
    final BackendResponse response = await ReviewsBackend.getFriendReviews(
      pageKey: 0,
      pageSize: reviewsPreview,
    );

    if (response.success) {
      reviews.value = response.payload;
    }
  }

  Future<List<Book>> loadNetworkBooks(int pageKey) async {
    final BackendResponse response = await BooksBackend.getNetworkBooks(
      pageKey: pageKey,
      query: '',
      pageSize: networkPageSize,
    );

    if (response.success) {
      return response.payload;
    }

    throw response.errorMessage;
  }
}
