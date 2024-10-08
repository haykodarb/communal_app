import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/loans/loans_controller.dart';
import 'package:get/get.dart';

class LoanInfoController extends GetxController {
  final Loan? inheritedLoan = Get.arguments['loan'];
  final Rx<Loan> loan = Loan.empty().obs;

  final RxBool loading = false.obs;
  final RxBool editing = false.obs;
  final RxBool deleting = false.obs;

  final RxBool loadingPage = false.obs;

  String? newReview = '';

  final LoansController? loansController = Get.arguments['loansController'];

  @override
  Future<void> onInit() async {
    if (inheritedLoan != null) {
      loan.value = inheritedLoan!;
      newReview = inheritedLoan!.review;
      loan.refresh();
    } else {
      loadingPage.value = true;

      final String loan_id = Get.arguments['loan_id'];

      final BackendResponse response = await LoansBackend.getLoanById(loan_id);

      if (response.success) {
        loan.value = response.payload;
        newReview = loan.value.review;
        loan.refresh();
      }

      loadingPage.value = false;
    }

    super.onInit();
  }

  void changeEditingState() {
    editing.value = !editing.value;
  }

  Future<void> withdrawLoanRequest() async {
    final bool? confirm = await Get.dialog(
      const CommonConfirmationDialog(
        title: 'Withdraw your request for this book?',
      ),
    );

    if (confirm != null && confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.deleteLoan(loan.value);

      if (response.success) {
        loansController?.removeItemById(inheritedLoan!.id);

        Get.back();
      } else {
        Get.dialog(
          CommonAlertDialog(title: response.payload),
        );
      }
    }
  }

  Future<void> acceptLoanRequest() async {
    final bool? confirm = await Get.dialog(
      const CommonConfirmationDialog(
        title: 'Accept this loan?',
      ),
    );

    if (confirm != null && confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.setLoanParameterTrue(loan.value, 'accepted');

      loading.value = false;

      if (response.success) {
        loan.value.accepted = true;
        loan.value.accepted_at = DateTime.now();
        loan.refresh();

        inheritedLoan?.accepted = true;
        inheritedLoan?.accepted_at = DateTime.now();
        loansController?.loanList.refresh();
      } else {
        Get.dialog(
          CommonAlertDialog(title: response.payload),
        );
      }
    }
  }

  Future<void> rejectLoanRequest() async {
    final bool? confirm = await Get.dialog(
      const CommonConfirmationDialog(
        title: 'Reject this loan?',
      ),
    );

    if (confirm != null && confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.setLoanParameterTrue(loan.value, 'rejected');

      if (response.success && inheritedLoan != null) {
        loansController?.loanList.removeWhere(
          (element) => element.id == inheritedLoan!.id,
        );
      }

      if (!response.success) {
        Get.dialog(
          const CommonAlertDialog(title: 'Could not reject this loan, please try again.'),
        );
      }

      Get.back();
    }
  }

  Future<void> markLoanReturned() async {
    final bool? confirm = await Get.dialog(
      const CommonConfirmationDialog(
        title: 'Mark this book as returned?',
      ),
    );

    if (confirm != null && confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.setLoanParameterTrue(loan.value, 'returned');

      if (response.success) {
        loan.value.returned = true;
        loan.value.returned_at = DateTime.now();
        loan.refresh();

        loansController?.loanList.removeWhere(
          (element) => element.id == inheritedLoan?.id,
        );
      } else {
        Get.dialog(
          const CommonAlertDialog(title: 'Could not mark book as returned, please try again.'),
        );
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
