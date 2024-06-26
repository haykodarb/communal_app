import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  Widget _bookCard(Book book) {
    return Builder(
      builder: (context) {
        final Color purple = Theme.of(context).colorScheme.tertiary;
        const Color green = Color(0xFF7DAE6B);

        return Obx(
          () => CommonLoadingBody(
            loading: book.loading.value,
            child: SizedBox(
              height: 200,
              width: double.maxFinite,
              child: Card(
                margin: EdgeInsets.zero,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: FutureBuilder(
                        future: BooksBackend.getBookCover(book),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CommonLoadingImage();
                          }

                          return Image.memory(
                            snapshot.data!,
                            gaplessPlayback: true,
                            fit: BoxFit.cover,
                          );
                        },
                      ),
                    ),
                    // const VerticalDivider(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30, right: 30, left: 30),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(height: 10),
                            Text(book.author),
                            const Divider(height: 10),
                            Container(
                              height: 30,
                              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                color: book.available ? green.withOpacity(0.25) : purple.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: book.available ? green : purple,
                                      shape: BoxShape.circle,
                                    ),
                                    height: 8,
                                    width: 8,
                                  ),
                                  const VerticalDivider(width: 10),
                                  Text(
                                    book.available ? 'available'.tr : 'loaned'.tr,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchRow(BookListController controller) {
    return Builder(builder: (context) {
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              height: 45,
              child: TextField(
                onChanged: controller.searchBooks,
                focusNode: controller.focusScope,
                onTapOutside: (event) {
                  controller.focusScope.unfocus();
                },
                cursorColor: Theme.of(context).colorScheme.onSurface,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding: EdgeInsets.zero,
                  isCollapsed: true,
                  border: InputBorder.none,
                  errorBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  prefixIcon: Icon(
                    Atlas.magnifying_glass,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  focusedBorder: InputBorder.none,
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
          const VerticalDivider(width: 5),
          IconButton(
            onPressed: () {},
            iconSize: 20,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              fixedSize: const Size(45, 45),
            ),
            icon: Icon(
              Atlas.funnel_sort,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const VerticalDivider(width: 5),
          IconButton(
            onPressed: () {},
            iconSize: 20,
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              fixedSize: const Size(45, 45),
            ),
            icon: Icon(
              Atlas.align_justify_down,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BookListController(),
      builder: (BookListController controller) {
        return Scaffold(
          drawer: CommonDrawerWidget(),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          appBar: AppBar(
            elevation: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
            title: const Text('My Books'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.goToAddBookPage,
            child: const Icon(
              Icons.add,
              size: 35,
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _searchRow(controller),
              ),
              Expanded(
                child: Obx(
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
                              padding: const EdgeInsets.all(10),
                              cacheExtent: 1000,
                              separatorBuilder: (context, index) {
                                return const SizedBox(
                                  height: 10,
                                );
                              },
                              itemBuilder: (context, index) {
                                final Book book = controller.userBooks[index];

                                return InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () async {
                                    if (controller.focusScope.hasFocus) {
                                      controller.focusScope.unfocus();
                                    }

                                    await Get.toNamed(
                                      RouteNames.bookOwnedPage,
                                      arguments: {
                                        'book': book,
                                        'controller': controller,
                                      },
                                    );

                                    if (controller.focusScope.hasFocus) {
                                      controller.focusScope.unfocus();
                                    }
                                  },
                                  child: _bookCard(book),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
