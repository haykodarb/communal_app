import 'package:auto_size_text/auto_size_text.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/routes.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class BookOwnedPage extends StatelessWidget {
  const BookOwnedPage({
    super.key,
    required this.bookId,
  });

  final String bookId;

  Widget _bookTitle(Book book) {
    return Builder(
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              AutoSizeText(
                book.title,
                maxLines: 2,
                minFontSize: 14,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              AutoSizeText(
                book.author,
                maxLines: 2,
                minFontSize: 12,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ownerReviewCard(BookOwnedController controller) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: InkWell(
            onTap: () {
              controller.expandCarouselItem.value =
                  !controller.expandCarouselItem.value;
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommonCircularAvatar(
                      profile: controller.book.value.owner,
                      radius: 20,
                    ),
                    const VerticalDivider(width: 10),
                    Text(
                      controller.book.value.owner.username,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 5),
                Expanded(
                  child: Obx(
                    () => Text(
                      controller.book.value.review ?? '',
                      overflow: TextOverflow.fade,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
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

  Widget _reviewCard(BookOwnedController controller, int index) {
    final Loan loan = controller.completedLoans[index];

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: () {
              controller.expandCarouselItem.value =
                  !controller.expandCarouselItem.value;
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
                        clickable: true,
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
                        overflow: controller.expandCarouselItem.value
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        maxLines:
                            controller.expandCarouselItem.value ? null : 4,
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

  Widget _reviewsTab(BookOwnedController controller) {
    return Builder(
      builder: (context) {
        return Center(
          child: Obx(
            () {
              if (controller.loadingCarousel.value) {
                return const CommonLoadingBody();
              }

              bool ownerHasReview = controller.book.value.review != null &&
                  controller.book.value.review!.isNotEmpty;

              final int reviewsCount =
                  controller.completedLoans.length + (ownerHasReview ? 1 : 0);

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
                            if (controller.carouselIndex.value == 0 ||
                                reviewsCount <= 1) {
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
                            itemCount: controller.completedLoans.length +
                                (ownerHasReview ? 1 : 0),
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
                                index - (ownerHasReview ? 1 : 0),
                              );
                            },
                          ),
                        ),
                        Obx(
                          () {
                            if (controller.carouselIndex.value ==
                                    reviewsCount - 1 ||
                                reviewsCount < 2) {
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
                    visible: controller.completedLoans.length +
                            (ownerHasReview ? 1 : 0) >=
                        2,
                    child: Container(
                      alignment: Alignment.center,
                      height: 10,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: controller.completedLoans.length +
                            (ownerHasReview ? 1 : 0),
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
                                    : Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.25),
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

  Widget _buttonRow(BookOwnedController controller) {
    return Builder(
      builder: (context) {
        return Stack(
          children: [
            Visibility(
              visible: (!controller.book.value.loaned ||
                  !controller.book.value.public),
              child: Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      onPressed: controller.editBook,
                      disabled: controller.deleting,
                      child: Text('Edit'.tr),
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: CommonButton(
                      type: CommonButtonType.tonal,
                      onPressed: controller.deleteBook,
                      loading: controller.deleting,
                      child: Text('Delete'.tr),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: controller.book.value.loaned,
              child: Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      onPressed: (_) {
                        if (controller.currentLoan.value != null) {
                          context.push(
                            '${RouteNames.loansPage}/${controller.currentLoan.value!.id}',
                          );
                        }
                      },
                      child: Text('View loan'.tr),
                    ),
                  ),
                ],
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
      init: BookOwnedController(bookId: bookId),
      builder: (BookOwnedController controller) {
        return Obx(
          () => CommonLoadingBody(
            loading: controller.firstLoad.value,
            child: Scaffold(
              appBar: AppBar(),
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainer,
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
                            flex: 4,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    offset: const Offset(2, 1),
                                    blurRadius: 20,
                                    spreadRadius: 12,
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                  ),
                                ],
                              ),
                              child: CommonBookCover(
                                controller.book.value,
                                expandOnTap: true,
                              ),
                            ),
                          ),
                          const Divider(height: 20),
                          Obx(() => _bookTitle(controller.book.value)),
                          const Divider(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(40),
                            ),
                            width: double.maxFinite,
                            height: 65,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Added'.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        DateFormat('dd/MM/yy',
                                                Get.locale?.languageCode)
                                            .format(controller
                                                .book.value.created_at),
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Visibility'.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        controller.book.value.public
                                            ? 'Public'.tr
                                            : 'Private'.tr,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Status'.tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        controller.book.value.loaned
                                            ? 'Loaned'.tr
                                            : 'Available'.tr,
                                        style: const TextStyle(fontSize: 16),
                                      ),
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
          ),
        );
      },
    );
  }
}
