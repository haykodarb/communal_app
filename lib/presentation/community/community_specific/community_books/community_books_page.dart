import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/community/community_specific/community_books/community_books_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class CommunityBooksPage extends StatelessWidget {
  const CommunityBooksPage({super.key});

  Widget _searchRow(CommunityBooksController controller) {
    return Builder(builder: (context) {
      return Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(5),
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
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  fillColor: Theme.of(context).colorScheme.surfaceContainer,
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
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              fixedSize: const Size(45, 45),
            ),
            icon: Icon(
              Atlas.horizontal_sliders_dots,
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
      init: CommunityBooksController(),
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: controller.reloadPage,
          child: Padding(
            padding: const EdgeInsets.only(right: 10, left: 10, bottom: 0),
            child: Column(
              children: [
                _searchRow(controller),
                Expanded(
                  child: Obx(
                    () => CommonLoadingBody(
                      loading: controller.firstLoad.value,
                      child: Obx(
                        () {
                          if (controller.booksLoaded.isEmpty) {
                            return const CustomScrollView(
                              slivers: [
                                SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      'No books found.',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return PagedMasonryGridView.count(
                            pagingController: PagingController.fromValue(
                              PagingState(itemList: controller.booksLoaded),
                              firstPageKey: 0,
                            ),
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            padding: const EdgeInsets.only(top: 10, bottom: 90),
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const AlwaysScrollableScrollPhysics(),
                            builderDelegate: PagedChildBuilderDelegate(
                              noItemsFoundIndicatorBuilder: (context) {
                                return const SizedBox(
                                  height: 100,
                                  child: Center(child: Text('No items found')),
                                );
                              },
                              itemBuilder: (context, item, index) {
                                final Book book = controller.booksLoaded[index];

                                return CommonKeepaliveWrapper(
                                  child: InkWell(
                                    onTap: () {
                                      Get.toNamed(
                                        RouteNames.communitySpecificBookPage,
                                        arguments: {
                                          'book': book,
                                          'community': controller.community,
                                        },
                                      );
                                    },
                                    child: CommonVerticalBookCard(
                                      book: book,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
