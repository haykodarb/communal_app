import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_empty_state.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/common/common_filter_bottomsheet.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/book/book_list_controller.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookListPage extends StatelessWidget {
  const BookListPage({super.key});

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
        // Lines up with the grid's 10px edges.
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
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          appBar: Responsive.isMobile(context)
              ? AppBar(elevation: 10, title: Text('My Books'.tr))
              : null,
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
              // The masonry of Search and profiles; loaned books get a ribbon.
              // The bottom padding keeps the last row clear of the + button.
              CommonGridView<Book>(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 90),
                maxColumns: 3,
                childBuilder: (Book book) => CommonVerticalBookCard(
                  book: book,
                ),
                controller: controller.listViewController,
                scrollController: controller.scrollController,
                isSliver: true,
                noItemsText: 'No books found in your library.'.tr,
                emptyState: () => CommonEmptyState(
                  icon: Atlas.library,
                  title: 'No books found in your library.'.tr,
                  actionLabel: 'Add book'.tr,
                  actionIcon: Icons.add,
                  onAction: controller.goToAddBookPage,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
