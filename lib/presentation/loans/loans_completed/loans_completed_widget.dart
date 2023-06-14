import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/loans/loans_completed/loans_completed_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoansCompletedWidget extends StatelessWidget {
  const LoansCompletedWidget({super.key});

  Widget _actionButtons(LoansCompletedController controller, Loan loan) {
    return SizedBox(
      height: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: OutlinedButton(
          onPressed: () {},
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info,
              ),
              VerticalDivider(width: 5),
              Text(
                'Info',
                style: TextStyle(fontSize: 16),
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
      init: LoansCompletedController(),
      builder: (LoansCompletedController controller) {
        return Obx(
          () {
            return CommonLoadingBody(
              isLoading: controller.loading.value,
              child: controller.loans.isEmpty
                  ? const Center(
                      child: Text(
                        'You have not\ncompleted any loans yet',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      itemCount: controller.loans.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Get.theme.colorScheme.primary,
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
                                Text(
                                  loan.loanee.id == UsersBackend.getCurrentUserId()
                                      ? loan.book.owner.username
                                      : loan.loanee.username,
                                ),
                                Text(loan.community.name),
                                Text(
                                  'Loan completed',
                                  style: TextStyle(
                                    color: Get.theme.colorScheme.secondary,
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
            );
          },
        );
      },
    );
  }
}
