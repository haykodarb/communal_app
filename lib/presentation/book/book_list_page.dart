import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  Widget _deletingBookIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Deleting book...',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(
            height: 50,
            width: 50,
            child: LoadingAnimationWidget.threeArchedCircle(
              color: Get.theme.colorScheme.primary,
              size: 50,
            ),
          )
        ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () => Get.toNamed(
              RouteNames.bookOwnedPage,
              arguments: {
                'book': book,
                'controller': controller,
              },
            ),
            child: SizedBox(
              height: 200,
              child: book.loading.value
                  ? _deletingBookIndicator()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: cover ?? const CommonLoadingImage(),
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
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                Text(
                                  book.author,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                Text(
                                  book.is_loaned ? 'Loaned' : 'Available',
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
          drawer: CommonDrawerWidget(),
          appBar: AppBar(
            title: const Text('Books'),
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
                return CommonLoadingBody(
                  isLoading: controller.loading.value,
                  child: RefreshIndicator(
                    onRefresh: controller.reloadBooks,
                    child: Obx(
                      () {
                        if (controller.userBooks.isEmpty) {
                          return const Center(
                            child: Text(
                              'You haven\'t added\nany books yet.',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        } else {
                          return ListView.separated(
                            itemCount: controller.userBooks.length,
                            padding: const EdgeInsets.all(20),
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
                                  return _bookCard(
                                    controller,
                                    book: book,
                                    cover: snapshot.hasData
                                        ? Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  );
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
