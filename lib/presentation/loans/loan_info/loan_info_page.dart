import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/book/book_detail_view.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_pill_button.dart';
import 'package:communal/presentation/common/common_user_link.dart';
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

  /// What the other person is to you, following the loan's state.
  String _role(Loan loan) {
    if (loan.isOwned) {
      return loan.returned
          ? 'Borrowed this book'.tr
          : loan.accepted
              ? 'Is borrowing this book'.tr
              : loan.rejected
                  ? 'Asked to borrow this book'.tr
                  : 'Wants to borrow this book'.tr;
    }

    return loan.returned
        ? 'Owner · you borrowed this book'.tr
        : loan.accepted
            ? "Owner · you're borrowing this book".tr
            : 'Owner · you asked to borrow this book'.tr;
  }

  /// The other person, like a contact: avatar, name, their role, and a
  /// button to message them about the handover.
  Widget _contactRow(Loan loan) {
    return Builder(
      builder: (context) {
        final Profile person = loan.isOwned ? loan.loanee : loan.book.owner;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              CommonCircularAvatar(
                profile: person,
                radius: 22,
                clickable: true,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonUserLink(
                      profile: person,
                      showAvatar: false,
                      fontSize: 15,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _role(loan),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              CommonPillButton(
                icon: Atlas.comment_dots_bold,
                label: 'Message'.tr,
                onPressed: (BuildContext context) => context.push(
                  '${RouteNames.messagesPage}/${person.id}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// The book row, linking to the book.
  Widget _bookRow(Loan loan) {
    return Builder(
      builder: (context) {
        return InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            context.push(loan.isOwned
                ? '${RouteNames.myBooks}/${loan.book.id}'
                : RouteNames.foreignBooksPage
                    .replaceFirst(':bookId', loan.book.id));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.book.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        loan.book.author,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.2,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                SizedBox(
                  height: 60,
                  child: CommonBookCover(loan.book, radius: 3),
                ),
              ],
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
    bool rejected = false,
  }) {
    return Builder(builder: (context) {
      final ColorScheme colors = Theme.of(context).colorScheme;
      final Color color = rejected
          ? colors.error
          : active
              ? colors.onSurface
              : colors.tertiaryContainer;

      return SizedBox(
        height: 80,
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 14,
              child: Text(
                active ? date : '',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 2),
            // A ring: the card's colour inside a coloured dot.
            Container(
              height: 20,
              width: 20,
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.surfaceContainer,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Requested → Accepted → Returned, with each step's real date. A rejected
  /// request reads the same, except the middle step says Rejected in red.
  Widget _timeline(Loan loan) {
    return Builder(
      builder: (context) {
        final ColorScheme colors = Theme.of(context).colorScheme;
        final double progress =
            loan.returned ? 1 : (loan.accepted || loan.rejected ? 0.5 : 0);

        String format(DateTime? date) =>
            DateFormat.yMMMd(Get.locale?.languageCode)
                .format(date ?? loan.created_at);

        return Stack(
          alignment: Alignment.center,
          children: [
            // The line sits behind the dots (top of the dot: 14 + 2 + 5,
            // centre 10 below that), filled up to the loan's step.
            Positioned(
              left: 40,
              right: 40,
              top: 38,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 900),
                curve: Curves.ease,
                builder: (context, value, _) => Row(
                  children: [
                    Expanded(
                      flex: (value * 1000).round(),
                      child: Container(height: 4, color: colors.onSurface),
                    ),
                    Expanded(
                      flex: ((1 - value) * 1000).round(),
                      child: Container(
                        height: 4,
                        color: colors.tertiaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timelineStep(
                  label: 'Requested'.tr,
                  date: format(loan.created_at),
                  active: true,
                ),
                loan.rejected
                    ? _timelineStep(
                        label: 'Rejected'.tr,
                        date: format(loan.rejected_at),
                        active: true,
                        rejected: true,
                      )
                    : _timelineStep(
                        label: 'Accepted'.tr,
                        date: format(loan.accepted_at),
                        active: loan.accepted,
                      ),
                _timelineStep(
                  label: 'Returned'.tr,
                  date: format(loan.returned_at),
                  active: loan.returned,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// One card for the loan's story: the book, the timeline and, once there
  /// is one, the review. The actions stay below it.
  Widget _loanCard(Loan loan, bool editing) {
    return Builder(
      builder: (context) {
        final Widget divider = Divider(
          height: 28,
          thickness: 1,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        );

        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.fromLTRB(10, 12, 10, 20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _bookRow(loan),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    divider,
                    _timeline(loan),
                    if (loan.review != null &&
                        (loan.accepted || loan.returned) &&
                        !editing) ...[
                      divider,
                      BookReviewItem(
                        author: loan.loanee,
                        text: loan.review!,
                        tag: loan.isOwned ? 'Review'.tr : 'Your review'.tr,
                        showAuthor: false,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
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
              // The review itself is in the loan card.
              return Column(
                children: [
                  Visibility(
                    visible: !loan.returned,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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

              // The review itself is in the loan card.
              return CommonButton(
                type: CommonButtonType.tonal,
                onPressed: controller.changeEditingState,
                child: Text('Edit review'.tr),
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Obx(
                    () {
                      final Loan loan = controller.loan.value;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _contactRow(loan),
                          _loanCard(loan, controller.editing.value),
                          const SizedBox(height: 28),
                          if (loan.isOwned)
                            _ownerBottomHalf(controller)
                          else if (loan.isBorrowed)
                            _borrowerBottomHalf(controller)
                          else
                            const Text('Error'),
                        ],
                      );
                    },
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
