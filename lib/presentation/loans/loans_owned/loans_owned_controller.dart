import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:get/get.dart';

class LoansOwnedController extends GetxController {
  final RxList<Loan> loans = <Loan>[].obs;
  final RxBool loading = true.obs;

  @override
  void onReady() {
    super.onReady();
    loadLoans();
  }

  Future<void> rejectLoan(Loan loan) async {
    final bool? confirm = await Get.dialog(
      const CommonConfirmationDialog(
        title: 'Reject this loan?',
      ),
    );

    if (confirm != null && confirm) {
      loan.book.loading.value = true;

      final BackendResponse response = await LoansBackend.setLoanParameterTrue(loan, 'rejected');

      if (response.success) {
        loans.remove(loan);
      }

      if (!response.success) {
        Get.dialog(
          const CommonAlertDialog(title: 'Could not reject this loan, please try again.'),
        );
      }

      loan.book.loading.value = false;
    }
  }

  Future<void> acceptLoan(Loan loan) async {
    final bool? confirm = await Get.dialog(
      const CommonConfirmationDialog(
        title: 'Approve of this loan?',
      ),
    );

    if (confirm != null && confirm) {
      loan.book.loading.value = true;

      final BackendResponse response = await LoansBackend.setLoanParameterTrue(loan, 'accepted');

      if (response.success) {
        loan.accepted = true;
        loans.refresh();
      } else {
        Get.dialog(
          CommonAlertDialog(title: response.payload),
        );
      }

      loan.book.loading.value = false;
    }
  }

  Future<void> markAsReturned(Loan loan) async {
    final bool? confirm = await Get.dialog(
      const CommonConfirmationDialog(
        title: 'Mark this book as returned?',
      ),
    );

    if (confirm != null && confirm) {
      loan.book.loading.value = true;

      final BackendResponse response = await LoansBackend.setLoanParameterTrue(loan, 'returned');

      if (response.success) {
        loans.remove(loan);
      } else {
        Get.dialog(
          const CommonAlertDialog(title: 'Could not mark book as returned, please try again.'),
        );
      }

      loan.book.loading.value = false;
    }
  }

  Future<void> loadLoans() async {
    loading.value = true;

    final BackendResponse response = await LoansBackend.getLoansWhere(LoansRequestType.userIsOwner);

    if (response.success) {
      loans.value = response.payload;
    }

    loading.value = false;
  }
}
