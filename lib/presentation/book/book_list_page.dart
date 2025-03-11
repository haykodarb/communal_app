import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_filter_bottomsheet.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

  Widget _bookCard(Book book) {
    return SizedBox(
      width: 600,
      child: InkWell(
        child: Builder(
          builder: (context) {
            final Color purple = Theme.of(context).colorScheme.tertiary;
            const Color green = Color(0xFF7DAE6B);

            return InkWell(
              onTap: () {
                context.push('${RouteNames.myBooks}/${book.id}');
              },
              child: Obx(
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
                          CommonBookCover(
                            book,
                            radius: 0,
                            height: 240,
                          ),
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
                                      color: Theme.of(context).colorScheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                      height: 1.25,
                                    ),
                                  ),
                                  const Divider(height: 5),
                                  Text(
                                    book.author,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w400,
                                      height: 1.25,
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                  Container(
                                    height: 30,
                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                    decoration: BoxDecoration(
                                      color: book.loaned ? purple.withOpacity(0.25) : green.withOpacity(0.25),
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
                                          book.loaned ? 'Loaned'.tr : 'Available'.tr,
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
              ),
            );
          },
        ),
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
          title: 'Order by'.tr,
          initialIndex: orderByIndex,
          options: ['Date'.tr, 'Title'.tr, 'Author'.tr],
          onIndexChange: controller.onOrderByIndexChanged,
        ),
        const Divider(height: 10),
        CommonFilterRow(
          title: 'Filter by'.tr,
          initialIndex: filterByIndex,
          options: ['All'.tr, 'Available'.tr, 'Loaned'.tr],
          onIndexChange: controller.onFilterByChanged,
        ),
      ],
    );
  }

  Widget _searchRow(BookListController controller) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, bottom: 2),
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
          drawer: Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          appBar: Responsive.isMobile(context) ? AppBar(elevation: 10, title: Text('My Books'.tr)) : null,
          floatingActionButton: FloatingActionButton(
            onPressed: () => controller.goToAddBookPage(context),
            child: const Icon(
              Icons.add,
              size: 35,
            ),
          ),
          body: CustomScrollView(
            controller: controller.scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: Responsive.isMobile(context) ? 0 : 20,
                ),
              ),
              SliverAppBar(
                title: _searchRow(controller),
                titleSpacing: 0,
                toolbarHeight: 55,
                centerTitle: true,
                automaticallyImplyLeading: false,
                floating: true,
              ),
              CommonListView<Book>(
                childBuilder: (Book book) => CommonKeepaliveWrapper(child: _bookCard(book)),
                separator: const Divider(height: 5),
                controller: controller.listViewController,
                scrollController: controller.scrollController,
                isSliver: true,
                noItemsText: 'No books found.\n\nYou can upload some with the floating button on the bottom right.'.tr,
              ),
            ],
          ),
        );
      },
    );
  }
}
