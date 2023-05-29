import 'package:biblioteca/backend/books_backend.dart';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/book.dart';
import 'package:biblioteca/models/community.dart';
import 'package:get/get.dart';

class CommunitySpecificController extends GetxController {
  final Community community = Get.arguments['community'];

  final RxList<Book> booksLoaded = <Book>[].obs;

  final RxBool loadingMore = false.obs;

  int loadingIndex = 0;

  @override
  void onInit() {
    super.onInit();
    loadBooks();
  }

  Future<void> reloadPage() async {
    loadingIndex = 0;
    booksLoaded.clear();
    await loadBooks();
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
