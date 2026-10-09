import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/book/book_detail_view.dart';
import 'package:communal/presentation/book/book_foreign/book_foreign_controller.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_status_badge.dart';
import 'package:communal/presentation/common/common_user_link.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BookForeignPage extends StatelessWidget {
  const BookForeignPage({super.key, required this.bookId, this.ownerId});

  final String bookId;
  final String? ownerId;

  /// Until the first loan check is done the button is laid out but hidden,
  /// then it fades in (no spinner). Actions after that show their spinner
  /// inside the button.
  Widget _buttonRow(BookForeignController controller) {
    return Obx(
      () => AnimatedOpacity(
        opacity: controller.loanChecked.value ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: IgnorePointer(
          ignoring: !controller.loanChecked.value,
          child: _button(controller),
        ),
      ),
    );
  }

  Widget _button(BookForeignController controller) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Expanded(
              child: Obx(
                () {
                  final Loan? currentLoan = controller.currentLoan.value;

                  final Book book = controller.book!;

                  bool requestByCurrentUser =
                      currentLoan?.loanee.isCurrentUser ?? false;

                  if (requestByCurrentUser) {
                    if (book.loaned) {
                      return CommonButton(
                        onPressed: (_) {
                          if (controller.currentLoan.value != null) {
                            context.push(
                                '${RouteNames.loansPage}/${controller.currentLoan.value!.id}');
                          }
                        },
                        child: Text('View loan'.tr),
                      );
                    }
                    return CommonButton(
                      type: CommonButtonType.outlined,
                      onPressed: controller.withdrawLoanRequest,
                      loading: controller.loading,
                      child: Text('Withdraw request'.tr),
                    );
                  }

                  if (book.loaned) {
                    return CommonButton(
                      type: controller.waitlisted.value
                          ? CommonButtonType.outlined
                          : CommonButtonType.filled,
                      onPressed: controller.toggleWaitlist,
                      loading: controller.loadingWaitlist,
                      child: Text(
                        controller.waitlisted.value
                            ? 'Stop notifying me'.tr
                            : 'Notify me when available'.tr,
                      ),
                    );
                  }

                  return CommonButton(
                    onPressed: controller.requestLoan,
                    loading: controller.loading,
                    child: Text(
                      'Request'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      tag: bookId,
      init: BookForeignController(bookId: bookId, ownerId: ownerId),
      builder: (BookForeignController controller) {
        return Obx(
          () {
            if (controller.firstLoad.value) return const CommonLoadingBody();

            if (controller.book == null) {
              return const Center(
                child: Text('Server error.'),
              );
            }

            final Book book = controller.book!;

            return BookDetailView(
              key: ValueKey(book.id),
              book: book,
              info: [
                BookInfoItem(
                  'Status'.tr,
                  Obx(() {
                    final bool requestByCurrentUser =
                        controller.currentLoan.value?.loanee.isCurrentUser ??
                            false;

                    // Laid out from the start so the row doesn't shift.
                    return AnimatedOpacity(
                      opacity: controller.loanChecked.value ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      child: CommonStatusBadge(
                        tone: book.loaned
                            ? StatusTone.loaned
                            : requestByCurrentUser
                                ? StatusTone.requested
                                : StatusTone.available,
                        label: book.loaned
                            ? (requestByCurrentUser
                                ? 'Loaned'.tr
                                : 'Unavailable'.tr)
                            : (requestByCurrentUser
                                ? 'Requested'.tr
                                : 'Available'.tr),
                      ),
                    );
                  }),
                ),
                BookInfoItem(
                  'Added'.tr,
                  Text(
                    DateFormat.yMMMd(Get.locale?.languageCode)
                        .format(book.created_at),
                  ),
                ),
                BookInfoItem(
                  'Owner'.tr,
                  CommonUserLink(profile: book.owner, fontSize: 15),
                ),
              ],
              actions: _buttonRow(controller),
            );
          },
        );
      },
    );
  }
}
