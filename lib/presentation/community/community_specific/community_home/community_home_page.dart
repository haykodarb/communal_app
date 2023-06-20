import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/community/community_specific/community_home/community_home_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityHomePage extends StatelessWidget {
  const CommunityHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityHomeController(),
      builder: (controller) {
        return CommonLoadingBody(
          loading: controller.firstLoad,
          child: RefreshIndicator(
            onRefresh: controller.reloadPage,
            child: Column(
              children: [
                Expanded(
                  child: Obx(
                    () {
                      if (controller.booksLoaded.isEmpty) {
                        return const CustomScrollView(
                          slivers: [
                            SliverFillRemaining(
                              child: Center(
                                child: Text(
                                  'There are no books\nin this community yet.',
                                  style: TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return ListView.separated(
                        itemCount: controller.booksLoaded.length + 1,
                        padding: const EdgeInsets.all(20),
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 20);
                        },
                        itemBuilder: (context, index) {
                          if (index == controller.booksLoaded.length && index != 0) {
                            return Center(
                              child: Obx(
                                () {
                                  if (controller.booksLoaded.length == controller.totalBookCount.value) {
                                    return const SizedBox.shrink();
                                  }

                                  return CommonLoadingBody(
                                    loading: controller.loadingMore,
                                    child: IconButton(
                                      onPressed: controller.loadBooks,
                                      alignment: Alignment.center,
                                      icon: Icon(
                                        Icons.more_horiz,
                                        color: Get.theme.colorScheme.primary,
                                        size: 50,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }

                          final Book book = controller.booksLoaded[index];

                          return InkWell(
                            onTap: () {
                              Get.toNamed(
                                RouteNames.communitySpecificBookPage,
                                arguments: {
                                  'book': book,
                                  'community': controller.community,
                                },
                              );
                            },
                            child: CommonBookCard(
                              book: book,
                              textChildren: [
                                Text(book.author),
                                Text(book.owner.username),
                              ],
                            ),
                          );
                        },
                      );
                    },
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
