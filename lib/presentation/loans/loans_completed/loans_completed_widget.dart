import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/loans/loans_completed/loans_completed_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LoansCompletedWidget extends StatelessWidget {
  const LoansCompletedWidget({super.key});

  Widget _loanCard(LoansCompletedController controller, Loan loan) {
    final DateTime dateToShow = loan.returned_at ?? DateTime.now();
    final bool is_borrowed = loan.loanee.id == UsersBackend.currentUserId;

    return Builder(
      builder: (BuildContext context) {
        return InkWell(
          onTap: () => controller.goToBookPage(loan),
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
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          onSelected: (value) {
                            if (value == 0) {
                              Get.toNamed(
                                RouteNames.messagesSpecificPage,
                                arguments: {
                                  'user': is_borrowed ? loan.owner : loan.loanee,
                                },
                              );
                            }
                          },
                          itemBuilder: (context) {
                            return <PopupMenuEntry>[
                              const PopupMenuItem(
                                value: 0,
                                child: Text('Chat'),
                              ),
                            ];
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 10),
                    Row(
                      children: [
                        Text('Loaned ${is_borrowed ? 'from' : 'to'} '),
                        CommonUsernameButton(
                          user: is_borrowed ? loan.owner : loan.loanee,
                        ),
                      ],
                    ),
                    const Divider(height: 10),
                    Text(
                      'Returned ${DateFormat.MMMEd().format(dateToShow.toLocal())}',
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
