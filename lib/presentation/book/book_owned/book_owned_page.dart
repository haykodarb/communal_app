import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookOwnedPage extends StatelessWidget {
  const BookOwnedPage({super.key});

  Widget _textInfo({required String label, required String text}) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            Container(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bookReview(BookOwnedController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(
        () {
          return _textInfo(
            label: 'Your Review',
            text: controller.book.value.review ?? 'You have not reviewed this book yet.',
          );
        },
      ),
    );
  }

  Widget _existingLoan(Loan loan) {
    return Builder(
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Borrowed by',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                alignment: Alignment.topLeft,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                Get.toNamed(
                  RouteNames.messagesSpecificPage,
                  arguments: {
                    'user': loan.loanee,
                  },
                );
              },
              child: Text(
                loan.loanee.username,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            const Divider(height: 20),
            Text(
              'Since',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            Text(DateFormat.yMMMd().format(loan.accepted_at!.toLocal()))
          ],
        );
      },
    );
  }

  Widget _bookInformation(BookOwnedController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Obx(
        () => controller.loading.value
            ? SizedBox.shrink()
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(
                    () => _textInfo(label: 'Read', text: controller.book.value.read ? 'Yes' : 'No'),
                  ),
                  const Divider(height: 20),
                  controller.currentLoan.value != null
                      ? Obx(
                          () => _existingLoan(controller.currentLoan.value!),
                        )
                      : _textInfo(label: 'Available', text: controller.book.value.available ? 'Yes' : 'No'),
                ],
              ),
      ),
    );
  }

  Widget _bookTitle(BookOwnedController controller) {
    return Builder(
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Text(
                controller.book.value.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                controller.book.value.author,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
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
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: controller.editBook,
                icon: const Icon(Icons.edit),
              ),
              const VerticalDivider(width: 5),
              IconButton(
                onPressed: controller.deleteBook,
                icon: const Icon(Icons.delete),
              ),
              const VerticalDivider(),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 30),
                  _bookTitle(controller),
                  const Divider(height: 30),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: AspectRatio(
                            aspectRatio: 3 / 4,
                            child: FutureBuilder(
                              future: BooksBackend.getBookCover(controller.book.value),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const CommonLoadingImage();
                                }

                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: _bookInformation(controller),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  _bookReview(controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
