import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class BookOwnedController extends GetxController {
  BookOwnedController({required this.bookId});

  final String bookId;
  Book? inheritedBook;

  final Rx<Book> book = Book.empty().obs;

  final RxBool loading = false.obs;
  final RxBool firstLoad = false.obs;
  final RxBool deleting = false.obs;

  final RxInt carouselIndex = 0.obs;
  final RxBool loadingCarousel = false.obs;
  final RxList<Loan> completedLoans = <Loan>[].obs;

  final RxBool expandCarouselItem = false.obs;

  final PageController reviewsPageController = PageController();

  BookListController? bookListController;
  ProfileOwnController? profileOwnController;

  Rxn<Loan> currentLoan = Rxn<Loan>();

  @override
  Future<void> onInit() async {
    if (Get.isRegistered<BookListController>()) {
      bookListController = Get.find<BookListController>();
    }

    if (Get.isRegistered<ProfileOwnController>()) {
      profileOwnController = Get.find<ProfileOwnController>();
    }

    reviewsPageController.addListener(() {
      carouselIndex.value = reviewsPageController.page?.toInt() ?? 0;
    });

    loadingCarousel.value = true;

    inheritedBook =
        bookListController?.listViewController.itemList.firstWhereOrNull(
      (element) => element.id == bookId,
    );

    inheritedBook ??=
        profileOwnController?.bookListController.itemList.firstWhereOrNull(
      (element) => element.id == bookId,
    );

    if (inheritedBook == null) {
      firstLoad.value = true;
      final BackendResponse response = await BooksBackend.getBookById(bookId);
      if (response.success) {
        book.value = response.payload;
      }
      firstLoad.value = false;
    } else {
      book.value = inheritedBook!;
    }

    await loadCurrentLoan();

    completedLoans.clear();

    final BackendResponse response =
        await LoansBackend.getCompletedLoansForItem(
      bookId: bookId,
    );

    if (response.success) {
      completedLoans.addAll(response.payload);
    }

    loadingCarousel.value = false;

    super.onInit();
  }

  Future<void> deleteBook(BuildContext context) async {
    final bool deleteConfirm = await showDialog<bool>(
          context: context,
          builder: (context) => CommonConfirmationDialog(
            title: 'Delete book?',
            confirmCallback: (_) => Navigator.of(context).pop(true),
            cancelCallback: (_) => Navigator.of(context).pop(false),
          ),
        ) ??
        false;

    if (deleteConfirm) {
      deleting.value = true;
      final BackendResponse response =
          await BooksBackend.deleteBook(book.value);

      if (response.success) {
        bookListController?.deleteBook(book.value);
        profileOwnController?.deleteBook(bookId);
        if (context.mounted) {
          context.pop();
        }
      } else {
        deleting.value = false;
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => CommonAlertDialog(title: response.payload),
          );
        }
      }
    }
  }

  Future<void> loadCurrentLoan() async {
    loading.value = true;

    final BackendResponse response =
        await LoansBackend.getCurrentLoanForBook(bookId);

    if (response.success) {
      currentLoan.value = response.payload;
      currentLoan.refresh();
    }

    loading.value = false;
  }

  Future<void> editBook(BuildContext context) async {
    context.push(
      '${RouteNames.myBooks}/$bookId/edit',
    );
  }
}
