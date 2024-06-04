import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/loans/loans_owned/loans_owned_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LoansOwnedWidget extends StatelessWidget {
  const LoansOwnedWidget({super.key});

  Widget _loanCard(LoansOwnedController controller, Loan loan) {
    final DateTime dateToShow = loan.accepted_at ?? loan.created_at;

    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: () => Get.toNamed(
            RouteNames.loanInfoPage,
            arguments: {
              'loan': loan,
              'loansOwnedController': controller,
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
                        PopupMenuButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.more_vert,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onSelected: (value) {
                            if (value == 0) {
                              Get.toNamed(RouteNames.messagesSpecificPage, arguments: {
                                'user': loan.loanee,
                              });
                            }

                            if (value == 1) {
                              controller.acceptLoan(loan);
                            }

                            if (value == 2) {
                              controller.rejectLoan(loan);
                            }

                            if (value == 3) {
                              controller.markAsReturned(loan);
                            }
                          },
                          itemBuilder: (context) {
                            if (loan.accepted) {
                              return <PopupMenuEntry>[
                                const PopupMenuItem(
                                  value: 0,
                                  child: Text('Chat'),
                                ),
                                const PopupMenuItem(
                                  value: 3,
                                  child: Text('Mark returned'),
                                ),
                              ];
                            } else {
                              return <PopupMenuEntry>[
                                const PopupMenuItem(
                                  value: 0,
                                  child: Text('Chat'),
                                ),
                                const PopupMenuItem(
                                  value: 1,
                                  child: Text('Accept'),
                                ),
                                const PopupMenuItem(
                                  value: 2,
                                  child: Text('Reject'),
                                ),
                              ];
                            }
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 10),
                    Row(
                      children: [
                        const Text('Requested by '),
                        CommonUsernameButton(user: loan.loanee),
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
      init: LoansOwnedController(),
      builder: (LoansOwnedController controller) {
        return Obx(
          () => CommonLoadingBody(
            loading: controller.loading.value,
            child: controller.loans.isEmpty
                ? const Center(
                    child: Text(
                      'You currently have no\noutgoing loans or requests',
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
