import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/community/community_specific/community_books/community_books_controller.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

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
          body: CustomScrollView(
            controller: communityController.scrollController,
            slivers: [
              SliverAppBar(
                title: _searchRow(controller),
                titleSpacing: 0,
                toolbarHeight: 55,
                centerTitle: true,
                automaticallyImplyLeading: false,
                floating: true,
              ),
              CommonGridView<Book>(
                isSliver: true,
                noItemsText: 'No books found in this community.',
                verticalSeparator: const VerticalDivider(width: 5),
                horizontalSeparator: const Divider(height: 5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
		scrollController: communityController.scrollController,
                controller: controller.listViewController,
                childBuilder: (Book book) => InkWell(
                  child: CommonVerticalBookCard(book: book),
                  onTap: () {
                    context.push(
                      RouteNames.foreignBooksPage.replaceFirst(':bookId', book.id),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
