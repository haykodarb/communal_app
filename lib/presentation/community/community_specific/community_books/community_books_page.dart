import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/community/community_specific/community_books/community_books_controller.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:communal/routes.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommunityBooksPage extends StatelessWidget {
  const CommunityBooksPage({super.key, required this.communityController});

  final CommunitySpecificController communityController;

  Widget _searchRow(CommunityBooksController controller) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: CommonSearchBar(
          searchCallback: controller.searchBooks,
          focusNode: controller.focusScope,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: communityController.booksController,
      builder: (controller) {
        return Scaffold(
          body: ExtendedNestedScrollView(
            floatHeaderSlivers: true,
            controller: communityController.scrollController,
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
            body: PagedMasonryGridView<int, Book>.count(
              pagingController: controller.pagingController,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              padding: const EdgeInsets.only(
                  top: 10, bottom: 20, right: 10, left: 10),
              crossAxisCount: 2,
              shrinkWrap: true,
              builderDelegate: PagedChildBuilderDelegate(
                noItemsFoundIndicatorBuilder: (context) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: Text('No books found.')),
                  );
                },
                itemBuilder: (context, item, index) {
                  return CommonKeepaliveWrapper(
                    child: InkWell(
                      onTap: () {
                        context.go(
                          '${RouteNames.communityListPage}/${communityController.communityId}/book/${item.id}',
                        );
                      },
                      child: CommonVerticalBookCard(
                        book: item,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
