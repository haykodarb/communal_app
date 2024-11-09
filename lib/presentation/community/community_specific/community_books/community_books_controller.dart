import 'dart:async';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommunityBooksController extends GetxController {
  CommunityBooksController({required this.communityId});
  final String communityId;

  final FocusNode focusScope = FocusNode();

  int loadingIndex = 0;
  String currentQuery = '';

  PagingController<int, Book> pagingController = PagingController(
    firstPageKey: 0,
  );

  Timer? searchDebounceTimer;
  Timer? loadMoreDebounceTimer;

  @override
  Future<void> onInit() async {
    super.onInit();

    pagingController.addPageRequestListener(loadBooks);
  }

  Future<void> loadBooks(int pageKey) async {
    final BackendResponse response = await BooksBackend.getBooksInCommunity(
      communityId,
      pageKey,
      currentQuery,
    );

    if (response.success) {
      List<Book> books = response.payload;
      if (books.length < 10) {
        pagingController.appendLastPage(books);
        return;
      }

      pagingController.appendPage(books, pageKey + books.length);
    }
  }

  Future<void> searchBooks(String string_query) async {
    searchDebounceTimer?.cancel();

    searchDebounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        currentQuery = string_query;

        pagingController.refresh();
      },
    );
  }
}
