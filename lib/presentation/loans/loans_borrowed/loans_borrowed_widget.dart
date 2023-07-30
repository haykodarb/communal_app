import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/loans/loans_borrowed/loans_borrowed_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LoansBorrowedWidget extends StatelessWidget {
  const LoansBorrowedWidget({super.key});

  Widget _actionButtons(LoansBorrowedController controller, Loan loan) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          const Expanded(
            flex: 2,
            child: SizedBox(),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Get.toNamed(RouteNames.messagesSpecificPage, arguments: {
                  'user': loan.book.owner,
                });
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat,
                  ),
                ],
              ),
            ),
          ),
          VerticalDivider(width: 10),
          Expanded(
            child: Visibility(
              visible: !loan.accepted,
              child: OutlinedButton(
                onPressed: () => controller.deleteLoan(loan),
                // style: OutlinedButton.styleFrom(shape: ContinuousRectangleBorder()),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.close,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookImage(Book book) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: SizedBox(
        child: FutureBuilder(
          future: BooksBackend.getBookCover(book),
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
    );
  }

  Widget _loanCard(Loan loan) {
    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          child: SizedBox(
            width: double.maxFinite,
            child: Card(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 1,
                    child: _bookImage(loan.book),
                  ),
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            loan.book.title,
                            style: TextStyle(
                              fontSize: 20,
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 10),
                          Text('Requested from ${loan.loanee.username}'),
                          const Divider(height: 10),
                          Text('In community ${loan.community.name}'),
                          const Divider(height: 10),
                          Text(
                            loan.accepted ? 'Loan approved' : 'Pending approval',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoansBorrowedController(),
      builder: (LoansBorrowedController controller) {
        return Obx(
          () => CommonLoadingBody(
            loading: controller.loading.value,
            child: controller.loans.isEmpty
                ? const Center(
                    child: Text(
                      'You have not made\nany requests yet',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    itemCount: controller.loans.length,
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Theme.of(context).colorScheme.primary,
                        height: 50,
                        thickness: 0.5,
                      );
                    },
                    itemBuilder: (context, index) {
                      final Loan loan = controller.loans[index];
                      return Column(
                        children: [
                          // _loanCard(loan),
                          CommonBookCard(
                            book: loan.book,
                            textChildren: [
                              Text('Requested from ${loan.loanee.username}'),
                              Text('In community ${loan.community.name}'),
                              Text(
                                loan.accepted ? 'Loan approved' : 'Pending approval',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 10),
                          _actionButtons(
                            controller,
                            loan,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
