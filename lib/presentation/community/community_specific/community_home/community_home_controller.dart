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
  final RxBool firstLoad = true.obs;

  int loadingIndex = 0;

  Timer? searchDebounceTimer;
  Timer? loadMoreDebounceTimer;

  @override
  Future<void> onInit() async {
    await searchBooks('');

    super.onInit();
  }

  Future<void> reloadPage() async {
    loadingIndex = 0;

    firstLoad.value = true;
    await searchBooks('');
    firstLoad.value = false;
  }

  Future<void> searchBooks(String string_query) async {
    searchDebounceTimer?.cancel();

    searchDebounceTimer = Timer(
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
}
