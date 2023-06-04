import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:get/get.dart';

class LoansBorrowedController extends GetxController {
  final RxList<Loan> loans = <Loan>[].obs;
  final RxBool loading = true.obs;

  @override
  void onReady() {
    super.onReady();
    loadLoans();
  }

  Future<void> deleteLoan(Loan loan) async {
    final bool? confirm = await Get.dialog(
      const CommonConfirmationDialog(
        title: 'Withdraw your request for this book?',
      ),
    );

    if (confirm != null && confirm) {
      loan.loading.value = true;
      final BackendResponse response = await LoansBackend.deleteLoan(loan);
      if (response.success) {
        loans.remove(loan);
        loan.loading.value = false;
      } else {
        Get.dialog(
          const CommonAlertDialog(title: 'Could not remove request, please try again.'),
        );
      }
    }
  }

  Future<void> loadLoans() async {
    loading.value = true;

    final BackendResponse response = await LoansBackend.getLoansWhere(LoansRequestType.userIsLoanee);

    if (response.success) {
      loans.value = response.payload;
    }

    loading.value = false;
  }
}
