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

  final Rxn<Loan> existingLoan = Rxn<Loan>();

  final RxBool loading = false.obs;

  @override
  Future<void> onReady() async {
    await checkLoanStatus();
    super.onReady();
  }

  Future<void> checkLoanStatus() async {
    loading.value = true;

    final BackendResponse currentLoanResponse = await LoansBackend.getCurrentLoanForBook(book);

    if (currentLoanResponse.success) {
      existingLoan.value = currentLoanResponse.payload;
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

      final BackendResponse response = await LoansBackend.requestBookLoanInCommunity(book, community);

      if (response.success) {
        existingLoan.value = response.payload;
      } else {
        Get.dialog(
          CommonAlertDialog(title: response.payload),
        );
      }

      loading.value = false;
    }
  }
}
