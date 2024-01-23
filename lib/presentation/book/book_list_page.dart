import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_item_card.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

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
            elevation: 10,
            title: const Text('My Books'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                ),
                child: TextField(
                  onChanged: controller.searchBooks,
                  cursorColor: Theme.of(context).colorScheme.onBackground,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    prefixIcon: Icon(
                      UniconsLine.search_alt,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    focusedErrorBorder: InputBorder.none,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    label: const Text(
                      'Search...',
                      textAlign: TextAlign.center,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.goToAddBookPage,
            child: const Icon(
              UniconsLine.plus,
            ),
          ),
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              child: RefreshIndicator(
                onRefresh: controller.reloadBooks,
                child: Obx(
                  () {
                    if (controller.userBooks.isEmpty) {
                      return const Center(
                        child: Text(
                          'You haven\'t added\nany books yet.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      return ListView.separated(
                        itemCount: controller.userBooks.length,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 20,
                          );
                        },
                        itemBuilder: (context, index) {
                          final Book book = controller.userBooks[index];

                          return InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () => Get.toNamed(
                              RouteNames.bookOwnedPage,
                              arguments: {
                                'book': book,
                                'controller': controller,
                              },
                            ),
                            child: CommonItemCard(
                              book: book,
                              height: 200,
                              children: [
                                CommonTextInfo(label: 'Author', text: book.author, size: 13),
                                CommonTextInfo(label: 'Available', text: book.available ? 'Yes' : 'No', size: 13),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
