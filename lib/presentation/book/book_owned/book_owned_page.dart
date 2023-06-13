import 'package:communal/backend/books_backend.dart';
import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BookOwnedPage extends StatelessWidget {
  const BookOwnedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BookOwnedController(),
      builder: (BookOwnedController controller) {
        return Scaffold(
          appBar: AppBar(
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(controller.book.title),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    height: 250,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: SizedBox(
                            child: FutureBuilder(
                              future: BooksBackend.getBookCover(controller.book),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }

                                return const CommonLoadingImage();
                              },
                            ),
                          ),
                        ),
                        const VerticalDivider(),
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Divider(),
                              Text(
                                controller.book.title,
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                              const Divider(),
                              Text(
                                controller.book.author,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Get.theme.colorScheme.primary,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      width: double.maxFinite,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Select Communities\nto share this book in',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: const Size.fromHeight(60),
                          ),
                          child: const Text('Edit'),
                        ),
                      ),
                      const VerticalDivider(),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final bool deleteConfirm = await Get.dialog<bool>(
                                  CommonConfirmationDialog(
                                    title: 'Confirm delete?',
                                    confirmCallback: () => Get.back<bool>(result: true),
                                    cancelCallback: () => Get.back<bool>(result: false),
                                  ),
                                ) ??
                                false;

                            if (deleteConfirm) {
                              controller.myBooksController.deleteBook(controller.book);
                              Get.back();
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Get.theme.colorScheme.error,
                            side: BorderSide(
                              color: Get.theme.colorScheme.error,
                            ),
                          ),
                          child: const Text('Delete'),
                        ),
                      ),
                    ],
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
