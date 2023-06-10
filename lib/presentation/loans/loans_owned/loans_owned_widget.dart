import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/loans/loans_owned/loans_owned_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoansOwnedWidget extends StatelessWidget {
  const LoansOwnedWidget({super.key});

  Widget _actionButtons(LoansOwnedController controller, Loan loan) {
    return SizedBox(
      height: 40,
      child: Builder(
        builder: (context) {
          if (loan.accepted) {
            return Row(
              children: [
                const VerticalDivider(width: 20),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.markAsReturned(loan),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.done,
                        ),
                        VerticalDivider(width: 5),
                        Text(
                          'Returned',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 20),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Get.toNamed(RouteNames.messagesSpecificPage, arguments: {
                        'user': loan.loanee,
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
              ],
            );
          } else {
            return SizedBox(
              height: 30,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const VerticalDivider(width: 20),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.acceptLoan(loan),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.done,
                          ),
                          VerticalDivider(width: 5),
                          Text(
                            'Approve',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 20),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => controller.rejectLoan(loan),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close,
                          ),
                          VerticalDivider(width: 5),
                          Text(
                            'Reject',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 20),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _bookCard(LoansOwnedController controller, Loan loan) {
    return SizedBox(
      height: 300,
      child: Obx(
        () {
          return CommonLoadingBody(
            isLoading: loan.loading.value,
            child: Column(
              children: [
                Card(
                  shadowColor: Get.theme.colorScheme.primary,
                  child: SizedBox(
                    height: 225,
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              AspectRatio(
                                aspectRatio: 3 / 4,
                                child: SizedBox(
                                  child: FutureBuilder(
                                    future: BooksBackend.getBookCover(loan.book),
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
                              const VerticalDivider(),
                              Expanded(
                                flex: 5,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text(
                                      loan.book.title,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    Text(loan.book.author),
                                    Text(loan.loanee.username),
                                    Text(loan.community.name),
                                    Text(
                                      loan.accepted ? 'Loan approved' : 'Pending approval',
                                      style: TextStyle(
                                        color: Get.theme.colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                _actionButtons(controller, loan),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoansOwnedController(),
      builder: (LoansOwnedController controller) {
        return Obx(
          () {
            return CommonLoadingBody(
              isLoading: controller.loading.value,
              child: controller.loans.isEmpty
                  ? const Center(
                      child: Text(
                        'You currently have no\noutgoing loans or requests',
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      itemCount: controller.loans.length,
                      separatorBuilder: (context, index) {
                        return Divider(
                          color: Get.theme.colorScheme.primary,
                          height: 50,
                          thickness: 0.5,
                        );
                      },
                      itemBuilder: (context, index) {
                        return _bookCard(
                          controller,
                          controller.loans[index],
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
