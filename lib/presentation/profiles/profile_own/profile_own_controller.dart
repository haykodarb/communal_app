import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileOwnController extends GetxController {
  RxBool loading = false.obs;
  final RxList<Book> userBooks = <Book>[].obs;
  final ScrollController scrollController = ScrollController();
  final Rx<ScrollPhysics> scrollPhysics = const ClampingScrollPhysics().obs;
  final RxInt currentTabIndex = 0.obs;

  // Future<void> goToEditPage() async {}
  void disableScroll() {
    scrollPhysics.value = const NeverScrollableScrollPhysics();
  }

  void enableScroll() {
    scrollPhysics.value = const ClampingScrollPhysics();
  }

  void onTabBarChange(int newIndex) {
    if (newIndex != currentTabIndex.value) {
      currentTabIndex.value = newIndex;
      currentTabIndex.refresh();
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();

    await loadBooks();
  }

  Future<void> loadBooks() async {
    loading.value = true;
    final BackendResponse response = await BooksBackend.getAllBooksForUser();
    loading.value = false;

    if (response.success) {
      userBooks.value = response.payload;
      userBooks.refresh();
    }
  }
}
