import 'package:auto_size_text/auto_size_text.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_button.dart';
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
        return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Visibility(
                visible: loan.isOwned,
                child: CommonCircularAvatar(
                  profile: loan.loanee,
                  color: Theme.of(context).colorScheme.secondary,
                  radius: 25,
                  clickable: true,
                ),
              ),
              Visibility(
                visible: !loan.isOwned,
                child: const Text(
                  'You requested this book from',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const VerticalDivider(width: 5),
              CommonButton(
                type: CommonButtonType.text,
                onPressed: (BuildContext context) {},
                expand: false,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                child: Text(
                  loan.isOwned
                      ? loan.loanee.username
                      : loan.book.owner.username,
                ),
              ),
              const VerticalDivider(width: 5),
              Visibility(
                visible: loan.isOwned,
                child: const Text('requested this book'),
              ),
            ],
          ),
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
          child: Card(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          loan.book.title,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const Divider(height: 10),
                        AutoSizeText(
                          loan.book.author,
                          maxLines: 2,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 15),
                  SizedBox(
                    height: 60,
                    child: CommonBookCover(
                      loan.book,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _timelineStep({
    required String label,
    required String date,
    required bool active,
  }) {
    return Builder(builder: (context) {
      return SizedBox(
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Text(
                active ? date : '',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                height: 30,
                width: 30,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeIn,
                      scale: active ? 1.5 : 1,
                      child: Container(
                        height: 20,
                        width: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                        alignment: Alignment.center,
                      ),
                    ),
                    AnimatedScale(
                      duration: const Duration(milliseconds: 500),
                      scale: active ? 1 : 0,
                      curve: Curves.easeIn,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                        height: 10,
                        width: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: active
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.tertiaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _datesCard(Loan loan) {
    return Builder(
      builder: (context) {
        return Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Estado de la solicitud',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Divider(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 500),
                          widthFactor:
                              loan.returned ? 1 : (loan.accepted ? 0.5 : 0),
                          alignment: Alignment.centerLeft,
                          child: Container(
                            height: 4,
                            alignment: Alignment.center,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 500),
                          alignment: Alignment.centerRight,
                          widthFactor:
                              loan.returned ? 0 : (loan.accepted ? 0.5 : 1),
                          child: Container(
                            height: 4,
                            alignment: Alignment.center,
                            color:
                                Theme.of(context).colorScheme.tertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _timelineStep(
                      label: 'Requested'.tr,
                      date: DateFormat('dd/MM/yy').format(loan.created_at),
                      active: true,
                    ),
                    const Expanded(child: SizedBox()),
                    _timelineStep(
                      label: 'Accepted'.tr,
                      date: DateFormat('dd/MM/yy').format(loan.created_at),
                      active: loan.accepted,
                    ),
                    const Expanded(child: SizedBox()),
                    _timelineStep(
                      label: 'Returned'.tr,
                      date: DateFormat('dd/MM/yy').format(loan.created_at),
                      active: loan.returned,
                    ),
                  ],
                ),
              ],
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Divider(height: 20),
                        CommonButton(
                          loading: controller.loading,
                          onPressed: controller.markLoanReturned,
                          child: Text('Mark as returned'.tr),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(
                  child: CommonButton(
                    loading: controller.loading,
                    onPressed: controller.acceptLoanRequest,
                    child: Text('Approve'.tr),
                  ),
                ),
                const VerticalDivider(width: 10),
                Expanded(
                  child: CommonButton(
                    type: CommonButtonType.tonal,
                    onPressed: controller.rejectLoanRequest,
                    child: Text('Reject'.tr),
                  ),
                ),
              ],
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
                      onFieldSubmitted: (_) => controller.onReviewSubmit(
                        context,
                      ),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: controller.loan.value.review ?? '',
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Write a review...'.tr,
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                        floatingLabelAlignment: FloatingLabelAlignment.start,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        filled: false,
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.15),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CommonButton(
                            onPressed: controller.onReviewSubmit,
                            loading: controller.loading,
                            child: Text('Submit'.tr),
                          ),
                        ),
                        const VerticalDivider(width: 10),
                        Expanded(
                          child: CommonButton(
                            type: CommonButtonType.tonal,
                            onPressed: controller.changeEditingState,
                            disabled: controller.loading,
                            child: Text('Cancel'.tr),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              if (loan.review == null) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CommonButton(
                      onPressed: controller.changeEditingState,
                      expand: true,
                      child: Text('Add review'.tr),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your review'.tr,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      const Divider(height: 5),
                      Text(
                        loan.review ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  CommonButton(
                    type: CommonButtonType.tonal,
                    onPressed: controller.changeEditingState,
                    child: Text('Edit review'.tr),
                  ),
                ],
              );
            }

            return CommonButton(
              onPressed: controller.withdrawLoanRequest,
              loading: controller.loading,
              child: Text('Withdraw request'.tr),
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
                          const Divider(height: 40),
                          Obx(
                            () => _datesCard(controller.loan.value),
                          ),
                          const Divider(height: 40),
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
        );
      },
    );
  }
}
