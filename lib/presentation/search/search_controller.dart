import 'dart:async';

import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:get/get.dart';

class SearchPageController extends GetxController {
  static const int pageSize = 20;
  final CommonListViewController<Book> bookListController = CommonListViewController(pageSize: pageSize);
  final CommonListViewController<Community> communityListController = CommonListViewController(pageSize: pageSize);
  final CommonListViewController<Profile> profileListController = CommonListViewController(pageSize: pageSize);
  String query = '';
  Timer? debounceTimer;

  final RxInt currentTabIndex = 0.obs;

  void onTabTapped(int value) {
    currentTabIndex.value = value;

    reloadCurrentPage();
  }

  void onQueryChanged(String value) {
    query = value;

    debounceTimer?.cancel();

    debounceTimer = Timer(
      const Duration(milliseconds: 300),
      reloadCurrentPage,
    );
  }

  void reloadCurrentPage() async {
    switch (currentTabIndex.value) {
      case 0:
        await bookListController.reloadList();
        break;
      case 1:
        await communityListController.reloadList();
        break;
      case 2:
        await profileListController.reloadList();
        break;
      default:
        break;
    }
  }

  @override
  void onInit() {
    super.onInit();
    bookListController.registerNewPageCallback(searchBooks);
    profileListController.registerNewPageCallback(searchUsers);
    communityListController.registerNewPageCallback(searchCommunities);
  }

  Future<List<Community>> searchCommunities(int pageKey) async {
    final BackendResponse response = await CommunitiesBackend.searchAllCommunities(
      pageKey: pageKey,
      pageSize: pageSize,
      query: query,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }

  Future<List<Profile>> searchUsers(int pageKey) async {
    final BackendResponse response = await UsersBackend.searchAllUsers(
      pageKey: pageKey,
      pageSize: pageSize,
      query: query,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }

  Future<List<Book>> searchBooks(int pageKey) async {
    final BackendResponse response = await BooksBackend.getBooksInAllCommunities(
      pageKey: pageKey,
      query: query,
      pageSize: pageSize,
    );

    if (response.success) {
      return response.payload;
    }

    return <Book>[];
  }
}
