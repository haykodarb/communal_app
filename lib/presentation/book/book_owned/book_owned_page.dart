import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BookOwnedPage extends StatelessWidget {
  const BookOwnedPage({super.key});

  Widget _textInfo({required String label, required String text}) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(label),
            ),
            Container(
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
                text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bottomActionButtons(BookOwnedController controller) {
    return Row(
      children: [
        const VerticalDivider(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: controller.editBook,
            child: const Text('Edit'),
          ),
        ),
        const VerticalDivider(width: 20),
        Expanded(
          child: OutlinedButton(
            onPressed: controller.deleteBook,
            child: const Text('Delete'),
          ),
        ),
        const VerticalDivider(width: 20),
      ],
    );
  }

  Widget _bookReview(BookOwnedController controller) {
    return Obx(
      () {
        return _textInfo(
          label: 'Review',
          text: controller.book.value.review ?? 'You have not reviewed this book yet.',
        );
      },
    );
  }

  Widget _existingLoan(BookOwnedController controller) {
    return _textInfo(
      label: 'Loan status',
      text: controller.currentLoan != null
          ? 'Currently loaned to: ${controller.currentLoan!.loanee.username}'
          : 'Not loaned.',
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
                Obx(
                  () => CommonBookCard(
                    book: controller.book.value,
                    elevation: 0,
                    height: 250,
                    textChildren: [
                      Text(controller.book.value.author),
                    ],
                  ),
                ),
                const Divider(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: Obx(
                        () => _textInfo(
                          label: 'Available',
                          text: controller.book.value.available ? 'Yes' : 'No',
                        ),
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: Obx(
                        () => _textInfo(
                          label: 'Read',
                          text: controller.book.value.read ? 'Yes' : 'No',
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 30),
                _existingLoan(controller),
                const Divider(height: 30),
                _bookReview(controller),
                const Expanded(child: SizedBox()),
                SizedBox(
                  height: 50,
                  child: _bottomActionButtons(controller),
                ),
                const Divider(height: 30),
              ],
            ),
          ),
        );
      },
    );
  }
}
