import 'dart:async';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/community/community_specific/community_books/community_books_controller.dart';
import 'package:communal/presentation/profiles/profile_other/profile_other_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificBookController extends GetxController {
  CommunitySpecificBookController({required this.bookId});

  final String bookId;
  late Book book;
  final RxString message = ''.obs;

  CommunityBooksController? communityBookController;
  ProfileOtherController? profileOtherController;

  final Rxn<Loan> currentLoan = Rxn<Loan>();

  final RxBool loading = true.obs;
  final RxBool firstLoad = false.obs;

  final RxInt carouselIndex = 0.obs;
  final RxBool loadingCarousel = false.obs;
  final RxList<Loan> completedLoans = <Loan>[].obs;

  final RxBool expandCarouselItem = false.obs;

  @override
  Future<void> onInit() async {
    firstLoad.value = true;

    if (Get.isRegistered<CommunityBooksController>()) {
      communityBookController = Get.find<CommunityBooksController>();
    }

    if (Get.isRegistered<ProfileOtherController>()) {
      profileOtherController = Get.find<ProfileOtherController>();
    }

    Book? tmp =
        communityBookController?.pagingController.itemList?.firstWhereOrNull(
      (element) => element.id == bookId,
    );

    tmp ??= profileOtherController?.userBooks.firstWhereOrNull(
      (element) => element.id == bookId,
    );

    if (tmp != null) {
      book = tmp;
    } else {
      final BackendResponse response = await BooksBackend.getBookById(bookId);
      if (response.success) {
        book = response.payload;
      }
    }

    firstLoad.value = false;
    checkLoanStatus();

    loadingCarousel.value = true;

    completedLoans.clear();

    final BackendResponse response =
        await LoansBackend.getCompletedLoansForItem(bookId: bookId);

    if (response.success) {
      completedLoans.addAll(response.payload);
    }

    loadingCarousel.value = false;

    super.onInit();
  }

  Future<void> checkLoanStatus() async {
    loading.value = true;

    final BackendResponse currentLoanResponse =
        await LoansBackend.getCurrentLoanForBook(bookId);

    if (currentLoanResponse.success) {
      currentLoan.value = currentLoanResponse.payload;
      message.value = '';
    }

    loading.value = false;
  }

  Future<void> requestLoan(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      builder: (context) => const CommonConfirmationDialog(
        title: 'Request loan for this book?',
      ),
      context: context,
    );

    if (confirm != null && confirm) {
      loading.value = true;

      final BackendResponse response = await LoansBackend.requestBookLoan(
        bookId: bookId,
      );

      if (response.success) {
        currentLoan.value = response.payload;
        loading.value = false;
      } else {
        if (context.mounted) {
          showDialog(
            builder: (context) => CommonAlertDialog(title: response.payload),
            context: context,
          );
        }
      }

      loading.value = false;
    }
  }
}
