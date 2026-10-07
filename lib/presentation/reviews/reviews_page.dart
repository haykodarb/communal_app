import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_review_card.dart';
import 'package:communal/presentation/reviews/reviews_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Every review your friends have written, newest first, loading more as you
/// scroll. Home shows the first few.
class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ReviewsController(),
      builder: (ReviewsController controller) {
        return Scaffold(
          appBar: AppBar(title: Text('Reviews by friends'.tr)),
          body: SafeArea(
            child: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                CommonListView<Loan>(
                  padding: const EdgeInsets.fromLTRB(15, 0, 15, 40),
                  separator: const SizedBox(height: 10),
                  isSliver: true,
                  scrollController: controller.scrollController,
                  noItemsText:
                      'Your friends have not reviewed any books yet.'.tr,
                  childBuilder: (Loan loan, _) => CommonKeepaliveWrapper(
                    child: CommonReviewCard(loan: loan, showReviewer: true),
                  ),
                  controller: controller.listViewController,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
