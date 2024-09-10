import 'dart:async';

import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookListController extends GetxController {
  final RxList<Book> userBooks = <Book>[].obs;
  final RxBool loading = true.obs;
  Timer? debounceTimer;
  final FocusNode focusScope = FocusNode();

  Rx<BooksQuery> query = BooksQuery().obs;

  @override
  Future<void> onReady() async {
    super.onReady();

    await reloadBooks();

    query.listen(
      (BooksQuery value) {
        reloadBooks();
      },
    );
  }

  Future<void> deleteBook(Book book) async {
    book.loading.value = true;

    final BackendResponse response = await BooksBackend.deleteBook(book);

    if (response.success) {
      userBooks.remove(book);
      userBooks.refresh();
    } else {
      book.loading.value = false;

      Get.dialog(
        CommonAlertDialog(title: '${response.payload}'),
      );
    }
  }

  Future<void> searchBooks(String stringQuery) async {
    debounceTimer?.cancel();

    debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        query.value.search_query = stringQuery.isEmpty ? null : stringQuery;
        query.refresh();
      },
    );
  }

  Future<void> updateBook(Book book) async {
    final int indexOfBook =
        userBooks.indexWhere((element) => element.id == book.id);

    if (indexOfBook >= 0) {
      userBooks[indexOfBook] = book;
      userBooks.refresh();
    }
  }

  Future<void> reloadBooks() async {
    loading.value = true;
    final BackendResponse response = await BooksBackend.getAllBooksForUser(
      query: query.value,
    );

    loading.value = false;

    if (response.success) {
      userBooks.value = response.payload;
      userBooks.refresh();
    }
  }

  Future<void> goToAddBookPage() async {
    final dynamic result = await Get.toNamed(RouteNames.bookCreatePage);

    if (result != null) {
      userBooks.add(result);
      userBooks.refresh();
    }
  }

  void onFilterByChanged(int value) {
    switch (value) {
      case 0:
        query.value.loaned = null;
        break;
      case 1:
        query.value.loaned = false;
        break;
      case 2:
        query.value.loaned = true;
        break;
      default:
        break;
    }

    query.refresh();
  }

  void onOrderByIndexChanged(int value) {
    switch (value) {
      case 0:
        query.value.order_by = 'created_at';
        break;
      case 1:
        query.value.order_by = 'title';
        break;
      case 2:
        query.value.order_by = 'author';
        break;
      default:
        break;
    }

    query.refresh();
  }
}
