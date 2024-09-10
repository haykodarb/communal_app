import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:get/get.dart';

class LoansController extends GetxController {
  RxList<Loan> loanList = <Loan>[].obs;
  Rx<LoansFilterParams> filterParams = LoansFilterParams().obs;

  RxBool firstLoad = true.obs;

  @override
  void onInit() {
    loadLoans();

    filterParams.listen((LoansFilterParams params) => loadLoans());

    super.onInit();
  }

  void removeItemById(String id) {
    loanList.removeWhere((element) => element.id == id);
    loanList.refresh();
  }

  void onSearchTextChanged(String value) {
    filterParams.value.currentIndex = 0;
    filterParams.value.searchQuery = value;
    filterParams.refresh();

    loadLoans();
  }

  void onOrderByValueChanged(int index) {
    filterParams.value.orderByDate = index == 0;
    filterParams.refresh();
  }

  void onFilterByOwnerChanged(int index) {
    switch (index) {
      case 0:
        filterParams.value.userIsLoanee = true;
        filterParams.value.userIsOwner = true;
        break;

      case 1:
        filterParams.value.userIsLoanee = false;
        filterParams.value.userIsOwner = true;
        break;

      case 2:
        filterParams.value.userIsLoanee = true;
        filterParams.value.userIsOwner = false;
        break;
      default:
        break;
    }

    filterParams.refresh();
  }

  void onFilterByStatusChanged(int index) {
    switch (index) {
      case 0:
        filterParams.value.allStatus = true;
        filterParams.value.accepted = false;
        filterParams.value.returned = false;
        filterParams.value.rejected = false;
        break;
      case 1:
        filterParams.value.allStatus = false;
        filterParams.value.accepted = false;
        filterParams.value.returned = false;
        filterParams.value.rejected = false;
        break;
      case 2:
        filterParams.value.allStatus = false;
        filterParams.value.accepted = true;
        filterParams.value.returned = false;
        filterParams.value.rejected = false;
        break;
      case 3:
        filterParams.value.allStatus = false;
        filterParams.value.accepted = true;
        filterParams.value.returned = true;
        filterParams.value.rejected = false;
        break;
    case 4: 
	filterParams.value.allStatus = false;
        filterParams.value.accepted = false;
        filterParams.value.returned = false;
        filterParams.value.rejected = true;
	break;
      default:
        break;
    }

    filterParams.refresh();
  }

  Future<void> loadLoans() async {
    firstLoad.value = true;

    final BackendResponse response = await LoansBackend.getLoansForUser(filterParams.value);

    if (response.success) {
      loanList.value = response.payload;
    }

    firstLoad.value = false;
  }
}
