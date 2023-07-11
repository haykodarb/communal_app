import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/loans/loans_borrowed/loans_borrowed_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoansBorrowedWidget extends StatelessWidget {
  const LoansBorrowedWidget({super.key});

  Widget _actionButtons(LoansBorrowedController controller, Loan loan) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Row(
          children: [
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
                    VerticalDivider(width: 5),
                    Text(
                      'Chat',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const VerticalDivider(width: 20),
            Expanded(
              child: Visibility(
                visible: !loan.accepted,
                child: OutlinedButton(
                  onPressed: () => controller.deleteLoan(loan),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close,
                      ),
                      VerticalDivider(width: 5),
                      Text(
                        'Withdraw',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
                    padding: const EdgeInsets.symmetric(vertical: 20),
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
                          CommonBookCard(
                            book: loan.book,
                            height: 225,
                            textChildren: [
                              Text(loan.book.author),
                              Text(loan.book.owner.username),
                              Text(loan.community.name),
                              Text(
                                loan.accepted ? 'Loan approved' : 'Pending approval',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          _actionButtons(controller, loan),
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
