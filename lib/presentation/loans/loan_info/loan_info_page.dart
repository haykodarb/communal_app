import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/loans/loan_info/loan_info_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LoanInfoPage extends StatelessWidget {
  const LoanInfoPage({
    super.key,
    required this.loanId,
    this.loan,
  });

  final String loanId;
  final Loan? loan;

  Widget _userData(Loan loan) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            CommonCircularAvatar(
              profile: loan.isOwned ? loan.loanee : loan.book.owner,
              radius: 25,
              clickable: true,
            ),
            const VerticalDivider(width: 5),
            Text(
              loan.isOwned ? loan.loanee.username : loan.book.owner.username,
            ),
            const VerticalDivider(width: 5),
            Container(
              decoration: BoxDecoration(
                color: loan.isOwned
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.25)
                    : Theme.of(context)
                        .colorScheme
                        .tertiary
                        .withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(40),
              ),
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              child: Text(
                loan.isOwned ? 'Loanee'.tr : 'Owner'.tr,
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
            context.push(loan.isOwned
                ? '${RouteNames.myBooks}/${loan.book.id}'
                : RouteNames.foreignBooksPage
                    .replaceFirst(':bookId', loan.book.id));
          },
          child: Container(
            padding:
                const EdgeInsets.only(left: 20, top: 20, bottom: 20, right: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            ),
            height: 140,
            child: Row(
              children: [
                CommonBookCover(loan.book, height: 120),
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
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
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
            Expanded(
              child: _dateContainer(
                'Requested'.tr,
                DateFormat('dd/MM/yy').format(loan.created_at),
              ),
            ),
            const VerticalDivider(width: 5),
            Visibility(
              visible: loan.rejected,
              child: Expanded(
                child: _dateContainer(
                  'Rejected'.tr,
                  loan.rejected_at == null
                      ? '-'
                      : DateFormat('dd/MM/yy').format(loan.rejected_at!),
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
                        'Approved'.tr,
                        loan.accepted_at == null
                            ? '-'
                            : DateFormat('dd/MM/yy', Get.locale!.languageCode)
                                .format(loan.accepted_at!),
                      ),
                    ),
                    const VerticalDivider(width: 5),
                    Expanded(
                      child: _dateContainer(
                        'Returned'.tr,
                        loan.returned_at == null
                            ? '-'
                            : DateFormat('dd/MM/yy', Get.locale!.languageCode)
                                .format(loan.returned_at!),
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
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${'Review by'.tr} ${controller.loan.value.loanee.username}',
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
                  ),
                  Visibility(
                    visible: !loan.returned,
                    child: Column(
                      children: [
                        const Divider(height: 20),
                        Obx(
                          () => CommonLoadingBody(
                            loading: controller.loading.value,
                            child: ElevatedButton(
                              onPressed: () =>
                                  controller.markLoanReturned(context),
                              child: Text('Mark as returned'.tr),
                            ),
                          ),
                        ),
                      ],
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
                        onPressed: () => controller.acceptLoanRequest(context),
                        child: Text('Approve'.tr),
                      ),
                    ),
                    const VerticalDivider(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => controller.rejectLoanRequest(context),
                        child: Text('Reject'.tr),
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
                    TextFormField(
                      minLines: 3,
                      maxLines: 10,
                      onChanged: controller.onReviewTextChanged,
                      onFieldSubmitted: (_) => controller.onReviewSubmit(),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: controller.loan.value.review ?? '',
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Write a review...'.tr,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Obx(
                      () => CommonLoadingBody(
                        loading: controller.loading.value,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: controller.onReviewSubmit,
                                child: Text('Submit'.tr),
                              ),
                            ),
                            const VerticalDivider(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: controller.changeEditingState,
                                child: Text('Cancel'.tr),
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
                  child: Text('Add review'.tr),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your review'.tr,
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
                    child: Text('Edit review'.tr),
                  ),
                ],
              );
            }

            return Obx(
              () => CommonLoadingBody(
                loading: controller.loading.value,
                child: ElevatedButton(
                  onPressed: () => controller.withdrawLoanRequest(context),
                  child: Text('Withdraw request'.tr),
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
    ScrollController scrollController = ScrollController();

    return GetBuilder(
      init: LoanInfoController(loanId: loanId, inheritedLoan: loan),
      builder: (LoanInfoController controller) {
        return Scaffold(
          appBar: AppBar(
            title: Responsive.isMobile(context) ? Text('Loan'.tr) : null,
          ),
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.loadingPage.value,
              child: Scrollbar(
                thumbVisibility: true,
                controller: scrollController,
                child: SingleChildScrollView(
                  controller: scrollController,
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
                                if (controller.loan.value.isOwned) {
                                  return _ownerBottomHalf(controller);
                                }

                                if (controller.loan.value.isBorrowed) {
                                  return _borrowerBottomHalf(controller);
                                }

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
