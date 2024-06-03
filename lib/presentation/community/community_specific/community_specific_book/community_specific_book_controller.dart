import 'dart:async';

import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:get/get.dart';

class CommunitySpecificBookController extends GetxController {
  final Book book = Get.arguments['book'];
  final Community community = Get.arguments['community'];

  final RxString message = ''.obs;

  final Rxn<Loan> currentLoan = Rxn<Loan>();

  final RxBool loading = true.obs;

  final RxInt carouselIndex = 0.obs;
  final RxBool loadingCarousel = false.obs;
  final RxList<Loan> completedLoans = <Loan>[].obs;

  final RxBool expandCarouselItem = false.obs;

  @override
  Future<void> onReady() async {
    checkLoanStatus();

    loadingCarousel.value = true;

    completedLoans.clear();

    final BackendResponse response = await LoansBackend.getCompletedLoansForItem(book: book);

    if (response.success) {
      completedLoans.addAll(response.payload);
    }
    loadingCarousel.value = false;

    super.onReady();
  }

  Future<void> checkLoanStatus() async {
    loading.value = true;

    final BackendResponse currentLoanResponse = await LoansBackend.getCurrentLoanForBook(book);

    if (currentLoanResponse.success) {
      currentLoan.value = currentLoanResponse.payload;
      message.value = '';
    }

    loading.value = false;
  }

  Future<void> requestLoan() async {
    final bool? confirm = await Get.dialog(
      const CommonConfirmationDialog(
        title: 'Request loan for this book?',
      ),
    );

    if (confirm != null && confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.requestItemLoanInCommunity(
        book: book,
        community: community,
      );

      if (response.success) {
        currentLoan.value = response.payload;
      } else {
        Get.dialog(
          CommonAlertDialog(title: response.payload),
        );
      }

      loading.value = false;
    }
  }
}
