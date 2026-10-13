import 'package:communal/backend/reviews_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/review.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReviewsController extends GetxController {
  static const int pageSize = 20;

  final ScrollController scrollController = ScrollController();

  final CommonListViewController<Review> listViewController =
      CommonListViewController(pageSize: pageSize);

  @override
  void onInit() {
    super.onInit();
    listViewController.registerNewPageCallback(loadReviews);
  }

  Future<List<Review>> loadReviews(int pageKey) async {
    final BackendResponse response = await ReviewsBackend.getFriendReviews(
      pageKey: pageKey,
      pageSize: pageSize,
    );

    if (response.success) {
      return response.payload;
    }

    throw response.errorMessage;
  }
}
