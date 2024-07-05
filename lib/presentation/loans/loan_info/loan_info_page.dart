import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/tools_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/loans/loan_info/loan_info_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class LoanInfoPage extends StatelessWidget {
  const LoanInfoPage({super.key});

  Widget _loanTitle(Loan loan) {
    return Builder(
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Text(
                loan.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Visibility(
                visible: loan.hasBook,
                child: Text(
                  loan.book?.author ?? '',
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _loanItemCover(Loan loan) {
    if (loan.book == null && loan.tool == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: FutureBuilder(
          future: loan.hasBook ? BooksBackend.getBookCover(loan.book!) : ToolsBackend.getToolImage(loan.tool!),
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
    );
  }

  Widget _ownedSideInformation(LoanInfoController controller) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Borrower',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              CommonUsernameButton(user: controller.loan.value.loanee),
              const Divider(),
              CommonTextInfo(
                label: 'Requested',
                text: DateFormat.yMMMd().format(controller.loan.value.created_at),
                size: 14,
              ),
              const Divider(),
              Obx(
                () => CommonLoadingBody(
                  loading: controller.loading.value,
                  size: 30,
                  child: controller.loan.value.accepted
                      ? CommonTextInfo(
                          label: 'Accepted',
                          text: controller.loan.value.accepted
                              ? DateFormat.yMMMd().format(controller.loan.value.accepted_at!)
                              : 'Pending',
                          size: 14,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MaterialButton(
                              onPressed: controller.acceptLoanRequest,
                              color: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.done,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  const VerticalDivider(width: 5),
                                  Text(
                                    'Accept',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            MaterialButton(
                              onPressed: controller.rejectLoanRequest,
                              color: Theme.of(context).colorScheme.tertiary,
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: Theme.of(context).colorScheme.onTertiary,
                                  ),
                                  const VerticalDivider(width: 5),
                                  Text(
                                    'Reject',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const Divider(),
              Builder(
                builder: (context) {
                  return Obx(
                    () {
                      if (controller.loading.value) return const SizedBox.shrink();

                      if (controller.loan.value.accepted) {
                        if (controller.loan.value.returned) {
                          return CommonTextInfo(
                            label: 'Returned',
                            text: controller.loan.value.returned
                                ? DateFormat.yMMMd().format(controller.loan.value.returned_at!)
                                : 'Pending',
                            size: 14,
                          );
                        } else {
                          return MaterialButton(
                            onPressed: controller.markLoanReturned,
                            color: Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.done,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                const VerticalDivider(width: 5),
                                Text(
                                  'Returned',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _borrowedSideInformation(LoanInfoController controller) {
    final Profile owner = controller.loan.value.owner;
    final bool isOwned = owner.id == UsersBackend.currentUserId;

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOwned ? 'Borrower' : 'Owner',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  CommonUsernameButton(user: isOwned ? controller.loan.value.loanee : owner),
                  const Divider(),
                  CommonTextInfo(
                    label: 'Requested',
                    text: DateFormat.yMMMd().format(controller.loan.value.created_at),
                    size: 14,
                  ),
                  const Divider(),
                  CommonTextInfo(
                    label: 'Accepted',
                    text: controller.loan.value.accepted
                        ? DateFormat.yMMMd().format(controller.loan.value.accepted_at!)
                        : 'Pending',
                    size: 14,
                  ),
                  const Divider(),
                  Builder(
                    builder: (context) {
                      if (!controller.loan.value.accepted && !controller.loan.value.rejected) {
                        return Obx(
                          () => CommonLoadingBody(
                            loading: controller.loading.value,
                            size: 30,
                            child: MaterialButton(
                              onPressed: controller.withdrawLoanRequest,
                              color: Theme.of(context).colorScheme.tertiary,
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.close,
                                    color: Theme.of(context).colorScheme.onTertiary,
                                  ),
                                  const VerticalDivider(width: 5),
                                  Text(
                                    'Withdraw',
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.onTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return CommonTextInfo(
                          label: 'Returned',
                          text: controller.loan.value.returned
                              ? DateFormat.yMMMd().format(controller.loan.value.returned_at!)
                              : 'Pending',
                          size: 14,
                        );
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ownedBookReviewField(LoanInfoController controller) {
    return Obx(
      () {
        return !controller.loan.value.accepted
            ? const SizedBox.shrink()
            : CommonTextInfo(
                label: 'Borrower\'s Review',
                text: controller.loan.value.review ?? 'User has not left a review yet',
                size: 14,
              );
      },
    );
  }

  Widget _borrowedBookReviewField(LoanInfoController controller) {
    return Builder(
      builder: (context) {
        if (!controller.loan.value.accepted) {
          if (controller.loan.value.hasTool) {
            return CommonTextInfo(
              label: 'Description',
              text: controller.loan.value.tool!.description,
              size: 14,
            );
          } else {
            return CommonTextInfo(
              label: 'Owner Review',
              text: controller.loan.value.book!.review ?? 'User has not reviewed this book yet.',
              size: 14,
            );
          }
        } else {
          return Obx(
            () {
              if (controller.editing.value) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      onChanged: controller.onReviewTextChanged,
                      controller: TextEditingController.fromValue(
                        TextEditingValue(text: controller.loan.value.review ?? ''),
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Review',
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                      keyboardType: TextInputType.multiline,
                    ),
                    // const Divider(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Obx(
                        () => CommonLoadingBody(
                          loading: controller.loading.value,
                          alignment: Alignment.centerRight,
                          size: 30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  controller.editing.value = false;
                                },
                                padding: EdgeInsets.zero,
                                alignment: Alignment.topRight,
                                icon: const Icon(
                                  Icons.close,
                                  size: 35,
                                ),
                              ),
                              IconButton(
                                onPressed: controller.onReviewSubmit,
                                padding: EdgeInsets.zero,
                                alignment: Alignment.topRight,
                                icon: const Icon(
                                  Icons.done,
                                  size: 35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Obx(
                  () => CommonLoadingBody(
                    loading: controller.deleting.value,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: CommonTextInfo(
                            label: 'Your Review',
                            text: controller.loan.value.review ?? 'Empty',
                            size: 14,
                          ),
                        ),
                        Visibility(
                          visible: controller.loan.value.review != null,
                          child: IconButton(
                            onPressed: controller.onReviewDelete,
                            alignment: Alignment.topRight,
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Atlas.trash,
                              size: 35,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: controller.changeEditingState,
                          padding: EdgeInsets.zero,
                          alignment: Alignment.topRight,
                          icon: Icon(
                            controller.loan.value.review == null ? Icons.add : Atlas.pencil_edit,
                            size: 35,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoanInfoController(),
      builder: (LoanInfoController controller) {
        return Scaffold(
          appBar: AppBar(),
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.loadingPage.value,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _loanTitle(controller.loan.value),
                      const Divider(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 5,
                            child: _loanItemCover(controller.loan.value),
                          ),
                          Expanded(
                            flex: 3,
                            child: controller.loan.value.loanee.id == UsersBackend.currentUserId
                                ? _borrowedSideInformation(controller)
                                : _ownedSideInformation(controller),
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      controller.loan.value.loanee.id == UsersBackend.currentUserId
                          ? _borrowedBookReviewField(controller)
                          : _ownedBookReviewField(controller),
                    ],
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
