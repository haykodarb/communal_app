import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/loans/loans_borrowed/loans_borrowed_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:unicons/unicons.dart';

class LoansBorrowedWidget extends StatelessWidget {
  const LoansBorrowedWidget({super.key});

  Widget _loanCard(LoansBorrowedController controller, Loan loan) {
    final DateTime dateToShow = loan.accepted_at ?? loan.created_at;

    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: () => Get.toNamed(
            RouteNames.loanInfoPage,
            arguments: {
              'loan': loan,
              'loansBorrowedController': controller,
            },
          ),
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
                          loan.name,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Obx(
                          () => CommonLoadingBody(
                            loading: loan.loading.value,
                            size: 30,
                            child: PopupMenuButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                UniconsLine.ellipsis_v,
                                color: Theme.of(context).colorScheme.onBackground,
                              ),
                              onSelected: (value) {
                                if (value == 0) {
                                  Get.toNamed(
                                    RouteNames.messagesSpecificPage,
                                    arguments: {
                                      'user': loan.owner,
                                    },
                                  );
                                }

                                if (value == 1) {
                                  controller.deleteLoan(loan);
                                }
                              },
                              itemBuilder: (context) {
                                if (loan.accepted) {
                                  return <PopupMenuEntry>[
                                    const PopupMenuItem(
                                      value: 0,
                                      child: Text('Chat'),
                                    ),
                                  ];
                                }
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
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 10),
                    Row(
                      children: [
                        const Text('Requested from '),
                        CommonUsernameButton(user: loan.owner),
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
