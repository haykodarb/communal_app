import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/loans/loans_borrowed/loans_borrowed_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LoansBorrowedWidget extends StatelessWidget {
  const LoansBorrowedWidget({super.key});

  Widget _loanCard(LoansBorrowedController controller, Loan loan) {
    final DateTime dateToShow = loan.accepted_at ?? loan.created_at;

    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          child: SizedBox(
            width: double.maxFinite,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loan.book.title,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        PopupMenuButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          onSelected: (value) {
                            if (value == 0) {
                              Get.toNamed(
                                RouteNames.messagesSpecificPage,
                                arguments: {
                                  'user': loan.book.owner,
                                },
                              );
                            }

                            if (value == 1) {
                              controller.deleteLoan(loan);
                            }
                          },
                          itemBuilder: (context) {
                            return <PopupMenuEntry>[
                              const PopupMenuItem(
                                value: 0,
                                child: Text('Chat'),
                              ),
                              const PopupMenuItem(
                                value: 1,
                                child: Text('Withdraw'),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 10),
                    Row(
                      children: [
                        const Text('Requested from '),
                        Text(
                          loan.book.owner.username,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(loan.accepted ? 'Loan approved' : 'Pending approval'),
                        Text(
                          DateFormat.MMMEd().format(
                            dateToShow.toLocal(),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 10),
                  ],
                ),
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
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    itemCount: controller.loans.length,
                    separatorBuilder: (context, index) {
                      return const Divider(
                        height: 20,
                      );
                    },
                    itemBuilder: (context, index) {
                      final Loan loan = controller.loans[index];
                      return _loanCard(controller, loan);
                    },
                  ),
          ),
        );
      },
    );
  }
}
