import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/loan.dart';
import 'package:get/get.dart';

class CommunitySpecificBookController extends GetxController {
  final Book book = Get.arguments['book'];
  final Community community = Get.arguments['community'];

  final RxString message = ''.obs;
  final Rxn<Loan> existingLoan = Rxn<Loan>();

  @override
  void onReady() {
    checkIfRequestAlreadyMade();
    super.onReady();
  }

  Future<void> checkIfRequestAlreadyMade() async {
    book.loading.value = true;
    message.value = '';

    final BackendResponse response = await LoansBackend.hasBookBeenRequestedByCurrentUser(book);

    if (response.success) {
      existingLoan.value = response.payload;
      print(existingLoan.value!.loanee.username);
      message.value = '';
    }

    book.loading.value = false;
  }

  Future<void> requestLoan() async {
    book.loading.value = true;
    message.value = '';

    final BackendResponse response = await LoansBackend.requestBookLoanInCommunity(book, community);

    if (response.success) {
      message.value = 'Book requested, please wait for user to confirm and contact them.';
      existingLoan.value = response.payload;
    } else {
      message.value = response.payload;
    }

    book.loading.value = false;
  }
}
