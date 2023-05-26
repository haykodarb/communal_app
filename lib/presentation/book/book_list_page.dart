import 'package:biblioteca/backend/books_backend.dart';
import 'package:biblioteca/models/book.dart';
import 'package:biblioteca/presentation/common/common_scaffold/common_scaffold_widget.dart';
import 'package:biblioteca/presentation/book/book_list_controller.dart';
import 'package:biblioteca/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  Widget _deletingBookIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Deleting book...',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(),
          )
        ],
      ),
    );
  }

  Widget _loadingImageIndicator() {
    return SizedBox(
      height: 50,
      width: 50,
      child: Center(
        child: CircularProgressIndicator(
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _bookCard(
    BookListController controller, {
    required Book book,
    Image? cover,
  }) {
    return Obx(
      () {
        return Card(
          child: InkWell(
            onTap: () => Get.toNamed(
              RouteNames.ownedBookPage,
              arguments: {
                'book': book,
                'controller': controller,
              },
            ),
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: book.deleting.value
                    ? _deletingBookIndicator()
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: cover ?? _loadingImageIndicator(),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.title,
                                    style: TextStyle(
                                      color: Get.theme.colorScheme.primary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    book.author,
                                    style: const TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                  const Text(
                                    'Prestado',
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BookListController(),
      builder: (BookListController controller) {
        return Scaffold(
          drawer: const CommonScaffoldWidget(),
          appBar: AppBar(
            title: const Text('My Books'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.goToAddBookPage,
            child: const Icon(
              Icons.add,
            ),
          ),
          body: Center(
            child: Obx(
              () {
                if (controller.loading.value) {
                  return const CircularProgressIndicator();
                } else {
                  return RefreshIndicator(
                    onRefresh: controller.reloadBooks,
                    child: Obx(
                      () {
                        if (controller.userBooks.isEmpty) {
                          return const Center(
                            child: Text(
                              'You haven\'t added\nany books yet.',
                              style: TextStyle(
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          return ListView.separated(
                            itemCount: controller.userBooks.length,
                            padding: const EdgeInsets.all(20),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 20,
                              );
                            },
                            itemBuilder: (context, index) {
                              final Book book = controller.userBooks[index];

                              return FutureBuilder(
                                future: BooksBackend.getBookCover(book),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return _bookCard(
                                      controller,
                                      book: book,
                                      cover: null,
                                    );
                                  } else {
                                    return _bookCard(
                                      controller,
                                      book: book,
                                      cover: Image.memory(snapshot.data!),
                                    );
                                  }
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
