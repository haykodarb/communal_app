import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:communal/presentation/common/common_confirmation_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BookOwnedPage extends StatelessWidget {
  const BookOwnedPage({super.key});

  Widget _bottomActionButtons(BookOwnedController controller) {
    return Row(
      children: [
        const VerticalDivider(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            child: Text('Edit'),
          ),
        ),
        const VerticalDivider(width: 20),
        Expanded(
          child: OutlinedButton(
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
            child: Text('Delete'),
          ),
        ),
        const VerticalDivider(width: 20),
      ],
    );
  }

  Widget _bookReview(BookOwnedController controller) {
    return Builder(
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.onBackground,
              width: 0.5,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          width: double.maxFinite,
          child: Text(
            controller.book.review ?? 'You have not reviewed this book yet.',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BookOwnedController(),
      builder: (BookOwnedController controller) {
        return Scaffold(
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonBookCard(
                  book: controller.book,
                  elevation: 0,
                  height: 250,
                  textChildren: [
                    Text(controller.book.author),
                    Text(controller.book.available ? 'Available' : 'Unavailable'),
                    Text(controller.book.read ? 'Read' : 'Not read'),
                  ],
                ),
                const Divider(height: 30),
                Expanded(
                  child: _bookReview(controller),
                ),
                const Divider(height: 30),
                SizedBox(
                  height: 50,
                  child: _bottomActionButtons(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
