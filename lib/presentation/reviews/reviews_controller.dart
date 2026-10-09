import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewsController extends GetxController {
  static const int pageSize = 20;

  final ScrollController scrollController = ScrollController();

  final CommonListViewController<Loan> listViewController =
      CommonListViewController(pageSize: pageSize);

  @override
  void onInit() {
    super.onInit();
    listViewController.registerNewPageCallback(loadReviews);
  }

  Future<List<Loan>> loadReviews(int pageKey) async {
    final BackendResponse response = await LoansBackend.getFriendReviews(
      pageKey: pageKey,
      pageSize: pageSize,
    );

    if (response.success) {
      return response.payload;
    }

    throw response.errorMessage;
  }
}
