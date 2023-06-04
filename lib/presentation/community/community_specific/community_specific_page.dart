import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/community/community_specific/community_drawer/community_drawer_widget.dart';
import 'package:communal/presentation/community/community_specific/community_specific_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunitySpecificPage extends StatelessWidget {
  const CommunitySpecificPage({super.key});

  Widget _bookCard(
    CommunitySpecificController controller, {
    required Book book,
    Image? cover,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
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
        child: SizedBox(
          height: 200,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: cover ?? const CommonLoadingImage(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        book.author,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        book.owner.username,
                        style: const TextStyle(
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text(controller.community.name),
          ),
          endDrawer: CommunityDrawerWidget(
            community: controller.community,
          ),
          body: Obx(
            () => CommonLoadingBody(
              isLoading: controller.firstLoad.value,
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
                                      return CommonLoadingBody(
                                        isLoading: controller.loadingMore.value,
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

                              return FutureBuilder(
                                future: BooksBackend.getBookCover(book),
                                builder: (context, snapshot) {
                                  return _bookCard(
                                    controller,
                                    book: book,
                                    cover: snapshot.hasData
                                        ? Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
