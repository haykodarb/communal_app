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

  @override
  Future<void> onInit() async {
    super.onInit();
    firstLoad.value = true;

    await loadBooks();

    await getTotalBooksCount();

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
    await loadBooks();
    firstLoad.value = false;
  }

  Future<void> loadBooks() async {
    loadingMore.value = true;

    final BackendResponse response = await BooksBackend.getBooksInCommunity(community, loadingIndex);

    if (response.success) {
      booksLoaded.addAll(response.payload);
      loadingIndex++;
    }

    loadingMore.value = false;
  }
}
