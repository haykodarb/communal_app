import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:get/get.dart';

class LoansCompletedController extends GetxController {
  final RxList<Loan> loans = <Loan>[].obs;
  final RxBool loading = true.obs;

  @override
  void onReady() {
    super.onReady();
    loadLoans();
  }

  Future<void> loadLoans() async {
    loading.value = true;

    final BackendResponse response = await LoansBackend.getLoansWhere(LoansRequestType.loanIsCompleted);

    if (response.success) {
      loans.value = response.payload;
    }

    loading.value = false;
  }
}
