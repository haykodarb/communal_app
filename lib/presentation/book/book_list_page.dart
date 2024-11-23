import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_filter_bottomsheet.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  Widget _bookCard(Book book) {
    return SizedBox(
      width: 600,
      child: Builder(
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
                      CommonBookCover(book, radius: 0),
                      // const VerticalDivider(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                book.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                ),
                              ),
                              const Divider(height: 5),
                              Text(
                                book.author,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                  height: 1.25,
                                ),
                              ),
                              const Expanded(child: Divider()),
                              Container(
                                height: 30,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: book.loaned
                                      ? purple.withOpacity(0.25)
                                      : green.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: book.loaned ? purple : green,
                                        shape: BoxShape.circle,
                                      ),
                                      height: 8,
                                      width: 8,
                                    ),
                                    const VerticalDivider(width: 10),
                                    Text(
                                      book.loaned
                                          ? 'loaned'.tr
                                          : 'available'.tr,
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
      ),
    );
  }

  Widget _bottomSheet(BookListController controller) {
    int filterByIndex = 0;

    if (controller.query.value.loaned != null) {
      filterByIndex = controller.query.value.loaned! ? 2 : 1;
    }

    int orderByIndex = 0;

    if (controller.query.value.order_by == 'title') {
      orderByIndex = 1;
    } else if (controller.query.value.order_by == 'author') {
      orderByIndex = 2;
    }

    return CommonFilterBottomsheet(
      children: [
        CommonFilterRow(
          title: 'Ordenar por',
          initialIndex: orderByIndex,
          options: const ['Fecha', 'Titulo', 'Autor'],
          onIndexChange: controller.onOrderByIndexChanged,
        ),
        const Divider(height: 10),
        CommonFilterRow(
          title: 'Filtrar por',
          initialIndex: filterByIndex,
          options: const ['Todos', 'Disponible', 'Prestado'],
          onIndexChange: controller.onFilterByChanged,
        ),
      ],
    );
  }

  Widget _searchRow(BookListController controller) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CommonSearchBar(
          searchCallback: controller.searchBooks,
          filterCallback: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => _bottomSheet(controller),
            );
          },
          focusNode: controller.focusScope,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BookListController(),
      builder: (BookListController controller) {
        return Scaffold(
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          appBar: AppBar(
            elevation: 10,
            title: const Text('My Books'),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => controller.goToAddBookPage(context),
            child: const Icon(
              Icons.add,
              size: 35,
            ),
          ),
          body: ExtendedNestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: _searchRow(controller),
                  titleSpacing: 0,
                  toolbarHeight: 55,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  floating: true,
                ),
              ];
            },
            body: Align(
              alignment: Alignment.topCenter,
              child: Obx(
                () => CommonLoadingBody(
                  loading: controller.loading.value,
                  child: Obx(
                    () {
                      if (controller.userBooks.isEmpty) {
                        return const Center(
                          child: Text(
                            'You haven\'t added any books yet. \nPress the plus button on the bottom right to get started.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      } else {
                        return ListView.separated(
                          itemCount: controller.userBooks.length,
                          padding: const EdgeInsets.only(
                              right: 10, left: 10, top: 5, bottom: 90),
                          cacheExtent: 2000,
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 5);
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

                                context.push(
                                  '${RouteNames.myBooks}/${book.id}',
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
        );
      },
    );
  }
}
