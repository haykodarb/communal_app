import 'dart:async';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class BookListController extends GetxController {
  static const int pageSize = 20;

  final CommonListViewController<Book> listViewController = CommonListViewController(pageSize: 20);
  final RxBool loading = true.obs;
  Timer? debounceTimer;
  final FocusNode focusScope = FocusNode();

  final ScrollController scrollController = ScrollController();

  Rx<BooksQuery> query = BooksQuery().obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    listViewController.registerNewPageCallback(loadBooks);

    query.listen(
      (BooksQuery value) {
        debounceTimer?.cancel();

        debounceTimer = Timer(
          const Duration(milliseconds: 500),
          () async {
            await listViewController.reloadList();
          },
        );
      },
    );
  }

  Future<void> deleteBook(Book book) async {
    book.loading.value = true;

    listViewController.itemList.removeWhere((element) => element.id == book.id);
    listViewController.itemList.refresh();
    listViewController.pageKey--;

    book.loading.value = false;
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
    final int indexOfBook = listViewController.itemList.indexWhere(
      (element) => element.id == book.id,
    );

    if (indexOfBook >= 0) {
      listViewController.itemList[indexOfBook] = book;
      listViewController.itemList.refresh();
    }
  }

  Future<List<Book>> loadBooks(int pageKey) async {
    final BackendResponse response = await BooksBackend.getAllBooksForUser(
      query: query.value,
      pageKey: pageKey,
      pageSize: pageSize,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }

  Future<void> goToAddBookPage(BuildContext context) async {
    context.push('${RouteNames.myBooks}${RouteNames.bookCreatePage}');
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
