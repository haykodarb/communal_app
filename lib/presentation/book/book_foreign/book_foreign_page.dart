import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/book/book_foreign/book_foreign_controller.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BookForeignPage extends StatelessWidget {
  const BookForeignPage({super.key, required this.bookId, this.ownerId});

  final String bookId;
  final String? ownerId;

  Widget _bookTitle(Book book) {
    return Builder(
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  book.author,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ownerReviewCard(BookForeignController controller) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: InkWell(
            onTap: () {
              controller.expandCarouselItem.value = !controller.expandCarouselItem.value;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommonCircularAvatar(
                      profile: controller.book!.owner,
                      radius: 20,
                      clickable: true,
                    ),
                    const VerticalDivider(width: 10),
                    Text(
                      controller.book?.owner.username ?? '',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
                const Divider(height: 5),
                Expanded(
                  child: Text(
                    controller.book?.review ?? '',
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _reviewCard(BookForeignController controller, Loan loan) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: () {
              controller.expandCarouselItem.value = !controller.expandCarouselItem.value;
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CommonCircularAvatar(
                        profile: loan.loanee,
                        radius: 20,
                        clickable: !loan.loanee.isCurrentUser,
                      ),
                      const VerticalDivider(width: 10),
                      CommonUsernameButton(user: loan.loanee),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: Obx(
                      () => Text(
                        loan.review ?? '',
                        overflow: controller.expandCarouselItem.value ? TextOverflow.visible : TextOverflow.ellipsis,
                        maxLines: controller.expandCarouselItem.value ? null : 4,
                      ),
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

  Widget _reviewsTab(BookForeignController controller) {
    return Builder(
      builder: (context) {
        return Center(
          child: Obx(
            () {
              if (controller.loadingCarousel.value) {
                return const CommonLoadingBody();
              }

              bool ownerHasReview = controller.book?.review != null && controller.book!.review!.isNotEmpty;

              final int reviewsCount = controller.completedLoans.length + (ownerHasReview ? 1 : 0);

              if (reviewsCount == 0) {
                return Center(
                  child: Text(
                    'No reviews'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Obx(
                          () {
                            if (controller.carouselIndex.value == 0 || reviewsCount <= 1) {
                              return const SizedBox();
                            }

                            return IconButton(
                              onPressed: () {
                                controller.reviewsPageController.previousPage(
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.easeIn,
                                );
                              },
                              icon: const Icon(Icons.chevron_left),
                            );
                          },
                        ),
                        Expanded(
                          child: PageView.builder(
                            itemCount: controller.completedLoans.length + (ownerHasReview ? 1 : 0),
                            scrollDirection: Axis.horizontal,
                            controller: controller.reviewsPageController,
                            onPageChanged: (index) {
                              controller.carouselIndex.value = index;
                            },
                            itemBuilder: (context, index) {
                              if (index == 0 && ownerHasReview) {
                                return _ownerReviewCard(controller);
                              }

                              return _reviewCard(
                                controller,
                                controller.completedLoans[index - (ownerHasReview ? 1 : 0)],
                              );
                            },
                          ),
                        ),
                        Obx(
                          () {
                            if (controller.carouselIndex.value == reviewsCount - 1 || reviewsCount < 2) {
                              return const SizedBox();
                            }

                            return IconButton(
                              onPressed: () {
                                controller.reviewsPageController.nextPage(
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.easeIn,
                                );
                              },
                              icon: const Icon(Icons.chevron_right),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: controller.completedLoans.length + (ownerHasReview ? 1 : 0) >= 2,
                    child: Container(
                      alignment: Alignment.center,
                      height: 10,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: controller.completedLoans.length + (ownerHasReview ? 1 : 0),
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Obx(
                            () => Container(
                              height: 15,
                              width: 15,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == controller.carouselIndex.value
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.primary.withOpacity(0.25),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buttonRow(BookForeignController controller) {
    return Builder(
      builder: (context) {
        return Obx(
          () {
            if (controller.loading.value) {
              return const SizedBox(
                height: 60,
                child: CommonLoadingBody(),
              );
            }

            final Loan? currentLoan = controller.currentLoan.value;

            final Book book = controller.book!;

            bool requestByCurrentUser = currentLoan?.loanee.isCurrentUser ?? false;

            return Stack(
              children: [
                Visibility(
                  visible: book.loaned && requestByCurrentUser,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.currentLoan.value != null) {
                        context.push('${RouteNames.loansPage}/${controller.currentLoan.value!.id}');
                      }
                    },
                    child: Text('View loan'.tr),
                  ),
                ),
                Visibility(
                  visible: !book.loaned && !requestByCurrentUser,
                  child: ElevatedButton(
                    onPressed: () => controller.requestLoan(context),
                    child: Text(
                      'Request'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !book.loaned && requestByCurrentUser,
                  child: OutlinedButton(
                    onPressed: () => controller.withdrawLoanRequest(context),
                    child: Text('Withdraw request'.tr),
                  ),
                ),
              ],
            );
          },
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

            return Scaffold(
              appBar: AppBar(),
              body: DefaultTabController(
                length: 2,
                child: SafeArea(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          const Expanded(
                            child: SizedBox(),
                          ),
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surfaceContainer,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      offset: const Offset(2, 1),
                                      blurRadius: 20,
                                      spreadRadius: 12,
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ],
                                ),
                                child: CommonBookCover(controller.book!),
                              ),
                            ),
                            const Divider(height: 20),
                            _bookTitle(controller.book!),
                            const Divider(height: 20),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              width: double.maxFinite,
                              height: 65,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Owner'.tr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        CommonUsernameButton(user: controller.book!.owner),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Added'.tr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Text(
                                          DateFormat('dd/MM/yy', Get.locale?.languageCode).format(
                                            controller.book!.created_at,
                                          ),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Status'.tr,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        Obx(() {
                                          if (controller.loading.value) {
                                            return const Text('');
                                          }

                                          final bool requestByCurrentUser =
                                              controller.currentLoan.value?.loanee.isCurrentUser ?? false;

                                          return Text(
                                            controller.book!.loaned
                                                ? (requestByCurrentUser ? 'Loaned'.tr : 'Unavailable'.tr)
                                                : (requestByCurrentUser ? 'Requested'.tr : 'Available'.tr),
                                          );
                                        }),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 20),
                            Expanded(
                              flex: 2,
                              child: _reviewsTab(controller),
                            ),
                            const Divider(height: 20),
                            _buttonRow(controller),
                            const Divider(height: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
