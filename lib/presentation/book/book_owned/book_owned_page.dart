import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BookOwnedPage extends StatelessWidget {
  const BookOwnedPage({super.key});

  Widget _currentLoanIndicator(BookOwnedController controller) {
    return Padding(
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
        child: !controller.book.is_loaned
            ? const Center(
                child: Text(
                  'Book is available.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                  ),
                ),
              )
            : Obx(
                () => CommonLoadingBody(
                  loading: controller.loading.value,
                  child: controller.currentLoan == null
                      ? const Center(
                          child: Text(
                            'Network error,\ncould not get current loan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${controller.currentLoan?.loanee.username}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
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
      init: BookOwnedController(),
      builder: (BookOwnedController controller) {
        return Scaffold(
          appBar: AppBar(
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(controller.book.title),
            ),
            actions: [
              IconButton(
                onPressed: () async {
                  final bool deleteConfirm = await Get.dialog<bool>(
                        CommonConfirmationDialog(
                          title: 'Delete book?',
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
                icon: const Icon(Icons.delete),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonBookCard(
                  book: controller.book,
                  height: 250,
                  textChildren: [
                    Text(controller.book.author),
                    Text(controller.book.is_loaned ? 'Loaned' : 'Available'),
                  ],
                ),
                Expanded(
                  child: _currentLoanIndicator(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
