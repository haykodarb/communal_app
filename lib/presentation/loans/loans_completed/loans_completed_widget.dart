import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/loans/loans_completed/loans_completed_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoansCompletedWidget extends StatelessWidget {
  const LoansCompletedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoansCompletedController(),
      builder: (LoansCompletedController controller) {
        return Obx(
          () => CommonLoadingBody(
            loading: controller.loading.value,
            child: Obx(
              () {
                if (controller.loans.isEmpty) {
                  return const Center(
                    child: Text(
                      'You have not\ncompleted any loans yet',
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                const Text(
                                  'Loaned ',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  loan.loanee.id == UsersBackend.currentUserId ? 'from ' : 'to ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: loan.loanee.id == UsersBackend.currentUserId
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.secondary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  loan.loanee.id == UsersBackend.currentUserId
                                      ? loan.book.owner.username
                                      : loan.loanee.username,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                          CommonBookCard(
                            book: loan.book,
                            textChildren: [
                              Text(loan.book.author),
                              Text(loan.community.name),
                            ],
                          ),
                          const Divider(),
                          // _actionButtons(controller, loan),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
