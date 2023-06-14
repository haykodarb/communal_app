import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_book_card.dart';
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

                              return InkWell(
                                onTap: () => Get.toNamed(
                                  RouteNames.bookOwnedPage,
                                  arguments: {
                                    'book': book,
                                    'controller': controller,
                                  },
                                ),
                                child: CommonBookCard(
                                  book: book,
                                  textChildren: [
                                    Text(book.author),
                                    Text(book.is_loaned ? 'Loaned' : 'Available'),
                                  ],
                                ),
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
