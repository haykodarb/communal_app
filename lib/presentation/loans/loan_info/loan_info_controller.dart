import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/loans/loans_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class LoanInfoController extends GetxController {
  LoanInfoController({
    required this.loanId,
    this.inheritedLoan,
  });

  final String loanId;
  Loan? inheritedLoan;

  final Rx<Loan> loan = Loan.empty().obs;

  final RxBool loading = false.obs;
  final RxBool editing = false.obs;
  final RxBool deleting = false.obs;

  final RxBool loadingPage = false.obs;

  String? newReview = '';

  LoansController? loansController;

  @override
  Future<void> onInit() async {
    loadingPage.value = true;
    if (Get.isRegistered<LoansController>()) {
      loansController = Get.find<LoansController>();
    }

    if (loansController != null) {
      inheritedLoan = loansController?.listViewController.itemList.firstWhereOrNull(
        (element) => element.id == loanId,
      );
    }

    if (inheritedLoan != null) {
      loan.value = inheritedLoan!;
      newReview = inheritedLoan!.review;
      loan.refresh();
    } else {
      final BackendResponse response = await LoansBackend.getLoanById(loanId);

      if (response.success) {
        loan.value = response.payload;
        newReview = loan.value.review;
        loan.refresh();
      }
    }

    loadingPage.value = false;
    super.onInit();
  }

  void changeEditingState() {
    editing.value = !editing.value;
  }

  Future<void> withdrawLoanRequest(BuildContext context) async {
    final bool confirm = await const CommonConfirmationDialog(
      title: 'Withdraw your request for this book?',
    ).open(context);

    if (confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.deleteLoan(loan.value);

      if (response.success) {
        loansController?.removeItemById(inheritedLoan!.id);

        if (!context.mounted) return;
        context.pop();
      } else {
        if (context.mounted) {
          CommonAlertDialog(title: response.payload).open(context);
        }
      }
    }
  }

  Future<void> acceptLoanRequest(BuildContext context) async {
    final bool confirm = await const CommonConfirmationDialog(
      title: 'Accept this loan?',
    ).open(context);

    if (confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.setLoanParameterTrue(loan.value, 'accepted');

      loading.value = false;

      if (response.success) {
        loan.value.accepted = true;
        loan.value.accepted_at = DateTime.now();
        loan.refresh();

        inheritedLoan?.accepted = true;
        inheritedLoan?.accepted_at = DateTime.now();
        loansController?.listViewController.itemList.refresh();
      } else {
        if (context.mounted) {
          CommonAlertDialog(title: response.payload).open(context);
        }
      }
    }
  }

  Future<void> rejectLoanRequest(BuildContext context) async {
    final bool confirm = await const CommonConfirmationDialog(
      title: 'Reject this loan?',
    ).open(context);

    if (confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.setLoanParameterTrue(loan.value, 'rejected');

      if (response.success && inheritedLoan != null) {
        loansController?.listViewController.itemList.removeWhere(
          (element) => element.id == inheritedLoan!.id,
        );
      }

      if (!response.success && context.mounted) {
        const CommonAlertDialog(
          title: 'Could not reject this loan, please try again.',
        ).open(context);
      }

      if (context.mounted) {
        context.pop();
      }
    }
  }

  Future<void> markLoanReturned(BuildContext context) async {
    final bool confirm = await const CommonConfirmationDialog(
      title: 'Mark this book as returned?',
    ).open(context);

    if (confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.setLoanParameterTrue(loan.value, 'returned');

      if (response.success) {
        loan.value.returned = true;
        loan.value.returned_at = DateTime.now();
        loan.refresh();

        loansController?.listViewController.itemList.removeWhere(
          (element) => element.id == inheritedLoan?.id,
        );
      } else {
        if (context.mounted) {
          const CommonAlertDialog(
            title: 'Could not mark book as returned, please try again.',
          ).open(context);
        }
      }

      loading.value = false;
    }
  }

  void onReviewTextChanged(String value) {
    if (value.isEmpty || value.length <= 1) {
      return;
    }
    newReview = value;
  }

  Future<void> onReviewDelete() async {
    deleting.value = true;

    final BackendResponse response = await LoansBackend.updateLoanReview(loan.value, null);

    if (response.success) {
      loan.value.review = null;
      loan.refresh();
      editing.value = false;
    }

    deleting.value = false;
  }

  Future<void> onReviewSubmit() async {
    loading.value = true;

    final BackendResponse response = await LoansBackend.updateLoanReview(loan.value, newReview);

    if (response.success) {
      loan.value.review = newReview;
      editing.value = false;
    }

    loading.value = false;
  }
}
