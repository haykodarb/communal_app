import 'dart:async';

import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:get/get.dart';

class CommunityHomeController extends GetxController {
  final Community community = Get.arguments['community'];

  final RxList<Book> booksLoaded = <Book>[].obs;

  final RxBool loadingMore = false.obs;
  final RxBool firstLoad = false.obs;

  final RxInt totalBookCount = 0.obs;

  int loadingIndex = 0;

  Timer? debounceTimer;

  @override
  Future<void> onInit() async {
    super.onInit();
    firstLoad.value = true;

    getTotalBooksCount();

    await loadBooks();

    firstLoad.value = false;
  }

  Future<void> getTotalBooksCount() async {
    final BackendResponse response = await BooksBackend.getBooksCountInCommunity(community);

    if (response.success) {
      totalBookCount.value = response.payload;
    }
  }

  Future<void> reloadPage() async {
    loadingIndex = 0;
    booksLoaded.clear();
    firstLoad.value = true;

    getTotalBooksCount();

    await loadBooks();
    firstLoad.value = false;
  }

  Future<void> searchBooks(String string_query) async {
    debounceTimer?.cancel();

    print(string_query);

    debounceTimer = Timer(
      const Duration(milliseconds: 500),
      () async {
        firstLoad.value = true;

        final BackendResponse response = await BooksBackend.getBooksInCommunity(community, 0, string_query);

        if (response.success) {
          booksLoaded.value = response.payload;
          booksLoaded.refresh();
          loadingIndex++;
        }

        firstLoad.value = false;
      },
    );
  }

  Future<void> loadBooks() async {
    loadingMore.value = true;

    final BackendResponse response = await BooksBackend.getBooksInCommunity(community, loadingIndex, 'moro');

    if (response.success) {
      booksLoaded.addAll(response.payload);
      loadingIndex++;
    }

    loadingMore.value = false;
  }
}
