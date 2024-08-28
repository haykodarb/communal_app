import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/loans/loan_info/loan_info_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LoanInfoPage extends StatelessWidget {
  const LoanInfoPage({super.key});

  Widget _userData(Loan loan) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            CommonCircularAvatar(
              profile: loan.isOwned ? loan.loanee : loan.owner,
              radius: 25,
              clickable: true,
            ),
            const VerticalDivider(width: 5),
            Text(
              loan.isOwned ? loan.loanee.username : loan.owner.username,
            ),
            const VerticalDivider(width: 5),
            Container(
              decoration: BoxDecoration(
                color: loan.isOwned
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.25)
                    : Theme.of(context).colorScheme.tertiary.withOpacity(0.25),
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              child: Text(
                loan.isOwned ? 'Loanee' : 'Owner',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _bookCard(Loan loan) {
    return Builder(
      builder: (context) {
        return InkWell(
          highlightColor: Colors.transparent,
          overlayColor: WidgetStateColor.transparent,
          onTap: () {
            Get.toNamed(
              loan.isOwned ? RouteNames.bookOwnedPage : RouteNames.communitySpecificBookPage,
              arguments: {
                'book': loan.book,
                'community': loan.community,
              },
            );
          },
          child: Container(
            padding: const EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            ),
            height: 140,
            child: Row(
              children: [
                CommonBookCover(loan.book),
                const VerticalDivider(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        loan.book.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const Divider(height: 5),
                      Text(
                        loan.book.author,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.2,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 40,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dateContainer(String label, String date) {
    return Builder(
      builder: (context) {
        return Container(
          height: 60,
          padding: const EdgeInsets.all(5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
              const Divider(height: 2),
              FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  date,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _datesCard(Loan loan) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Expanded(child: _dateContainer('Requested', DateFormat('d/MM/yy').format(loan.created_at))),
            const VerticalDivider(width: 5),
            Visibility(
              visible: loan.rejected,
              child: Expanded(
                child: _dateContainer(
                  'Rejected',
                  loan.rejected_at == null ? '-' : DateFormat('d/MM/yy').format(loan.rejected_at!),
                ),
              ),
            ),
            Visibility(
              visible: !loan.rejected,
              child: Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: _dateContainer(
                        'Approved',
                        loan.accepted_at == null ? '-' : DateFormat('d/MM/yy').format(loan.accepted_at!),
                      ),
                    ),
                    const VerticalDivider(width: 5),
                    Expanded(
                      child: _dateContainer(
                        'Returned',
                        loan.returned_at == null ? '-' : DateFormat('d/MM/yy').format(loan.returned_at!),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _ownerBottomHalf(LoanInfoController controller) {
    return Builder(
      builder: (context) {
        return Obx(
          () {
            final Loan loan = controller.loan.value;

            if (loan.rejected) return const SizedBox.shrink();

            if (loan.accepted || loan.returned) {
              return Column(
                children: [
                  Visibility(
                    visible: loan.review != null,
                    child: Column(
                      children: [
                        Text(
                          'Review by ${controller.loan.value.loanee.username}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          loan.review ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: !loan.returned,
                    child: Obx(
                      () => CommonLoadingBody(
                        loading: controller.loading.value,
                        child: ElevatedButton(
                          onPressed: controller.markLoanReturned,
                          child: const Text('Mark as returned'),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return Obx(
              () => CommonLoadingBody(
                loading: controller.loading.value,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.acceptLoanRequest,
                        child: const Text('Approve'),
                      ),
                    ),
                    const VerticalDivider(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.rejectLoanRequest,
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _borrowerBottomHalf(LoanInfoController controller) {
    return Builder(
      builder: (context) {
        return Obx(
          () {
            final Loan loan = controller.loan.value;

            if (loan.rejected) return const SizedBox.shrink();

            if (loan.accepted || loan.returned) {
              if (controller.editing.value) {
                return Column(
                  children: [
                    TextField(
                      minLines: 3,
                      maxLines: 10,
                      onChanged: controller.onReviewTextChanged,
                      controller: TextEditingController.fromValue(
                        TextEditingValue(text: controller.loan.value.review ?? ''),
                      ),
                      style: const TextStyle(fontSize: 13, height: 1.3),
                      decoration: InputDecoration(
                        hintText: 'Write a review...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 0.5,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 10),
                    Obx(
                      () => CommonLoadingBody(
                        loading: controller.loading.value,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.onReviewSubmit,
                                child: const Text('Submit'),
                              ),
                            ),
                            const VerticalDivider(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.changeEditingState,
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }

              if (loan.review == null) {
                return ElevatedButton(
                  onPressed: controller.changeEditingState,
                  child: const Text('Add review'),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your review',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        loan.review ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  ElevatedButton(
                    onPressed: controller.changeEditingState,
                    child: const Text('Edit review'),
                  ),
                ],
              );
            }

            return Obx(
              () => CommonLoadingBody(
                loading: controller.loading.value,
                child: ElevatedButton(
                  onPressed: controller.withdrawLoanRequest,
                  child: const Text('Withdraw request'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoanInfoController(),
      builder: (LoanInfoController controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Loan'),
          ),
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.loadingPage.value,
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Obx(
                              () => _userData(controller.loan.value),
                            ),
                            const Divider(height: 20),
                            Obx(
                              () => _bookCard(controller.loan.value),
                            ),
                            const Divider(height: 20),
                            Obx(
                              () => _datesCard(controller.loan.value),
                            ),
                            const Divider(height: 20),
                            Obx(
                              () {
                                if (controller.loan.value.isOwned) return _ownerBottomHalf(controller);

                                if (controller.loan.value.isBorrowed) return _borrowerBottomHalf(controller);

                                return const Text('Error');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
