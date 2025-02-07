import 'dart:async';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityBooksController extends GetxController {
  static const int pageSize = 20;

  CommunityBooksController({required this.communityId});
  final String communityId;

  final FocusNode focusScope = FocusNode();

  int loadingIndex = 0;
  String currentQuery = '';

  final CommonListViewController<Book> listViewController = CommonListViewController(pageSize: pageSize);

  Timer? searchDebounceTimer;

  @override
  Future<void> onInit() async {
    super.onInit();

    listViewController.registerNewPageCallback(loadBooks);
  }

  Future<List<Book>> loadBooks(int pageKey) async {
    final BackendResponse response = await BooksBackend.getBooksInCommunity(
      communityId: communityId,
      pageKey: pageKey,
      query: currentQuery,
      pageSize: pageSize,
    );

    if (response.success) {
      List<Book> books = response.payload;

      return books;
    }

    return [];
  }

  Future<void> searchBooks(String string_query) async {
    searchDebounceTimer?.cancel();

    searchDebounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        currentQuery = string_query;

        await listViewController.reloadList();
      },
    );
  }
}
