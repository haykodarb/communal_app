import 'package:biblioteca/backend/books_backend.dart';
import 'package:biblioteca/models/book.dart';
import 'package:biblioteca/presentation/common/common_loading_image.dart';
import 'package:biblioteca/presentation/community/community_specific/community_drawer/community_drawer_widget.dart';
import 'package:biblioteca/presentation/community/community_specific/community_specific_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class CommunitySpecificPage extends StatelessWidget {
  const CommunitySpecificPage({super.key});

  Widget _loadingImageIndicator() {
    return SizedBox(
      height: 50,
      width: 50,
      child: Center(
        child: CircularProgressIndicator(
          color: Get.theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _bookCard(
    CommunitySpecificController controller, {
    required Book book,
    Image? cover,
  }) {
    return Card(
      child: InkWell(
        onTap: () {},
        child: SizedBox(
          height: 200,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: cover ?? const CommonLoadingImage(),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                            color: Get.theme.colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          book.author,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${book.ownerName}',
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
          body: RefreshIndicator(
            onRefresh: controller.reloadPage,
            child: Column(
              children: [
                Expanded(
                  child: Obx(
                    () {
                      return ListView.separated(
                        itemCount: controller.booksLoaded.length + 1,
                        padding: const EdgeInsets.all(20),
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 20,
                          );
                        },
                        itemBuilder: (context, index) {
                          if (index == controller.booksLoaded.length) {
                            return Center(
                              child: SizedBox(
                                height: 50,
                                child: Obx(
                                  () {
                                    return controller.loadingMore.value
                                        ? const Center(
                                            child: SizedBox(
                                              width: 30,
                                              height: 30,
                                              child: CircularProgressIndicator(),
                                            ),
                                          )
                                        : TextButton(
                                            onPressed: controller.loadBooks,
                                            child: const Text(
                                              'More...',
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          );
                                  },
                                ),
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
                                cover: snapshot.hasData ? Image.memory(snapshot.data!) : null,
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
        );
      },
    );
  }
}
