import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_responsive_page.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/community/community_specific/community_specific_book/community_specific_book_controller.dart';
import 'package:communal/routes.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommunitySpecificBookPage extends StatelessWidget {
  const CommunitySpecificBookPage({super.key, required this.bookId});

  final String bookId;

  Widget _bookTitle(Book book) {
    return Builder(
      builder: (context) {
        return Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Text(
                book.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                book.author,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ownerReviewCard(CommunitySpecificBookController controller) {
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: InkWell(
          onTap: () {
            controller.expandCarouselItem.value =
                !controller.expandCarouselItem.value;
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CommonCircularAvatar(
                      profile: controller.book.owner,
                      radius: 20,
                      clickable: true,
                    ),
                    const VerticalDivider(width: 10),
                    CommonUsernameButton(user: controller.book.owner),
                  ],
                ),
                const Divider(),
                SingleChildScrollView(
                  child: Obx(
                    () => Text(
                      controller.book.review ?? '',
                      overflow: controller.expandCarouselItem.value
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      maxLines: controller.expandCarouselItem.value ? null : 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _reviewCard(CommunitySpecificBookController controller, int index) {
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Theme.of(context).colorScheme.surface,
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
                  SingleChildScrollView(
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

  Widget _reviewsTab(CommunitySpecificBookController controller) {
    return Builder(
      builder: (context) {
        return Center(
          child: Obx(
            () {
              if (controller.loadingCarousel.value) {
                return SizedBox(
                  height: 100,
                  width: double.maxFinite,
                  child: LoadingAnimationWidget.threeArchedCircle(
                    color: Theme.of(context).colorScheme.primary,
                    size: 30,
                  ),
                );
              }

              bool ownerHasReview = controller.book.review != null &&
                  controller.book.review!.isNotEmpty;

              if (controller.completedLoans.isEmpty && !ownerHasReview) {
                return const Center(child: Text('No reviews.'));
              }

              return Column(
                children: [
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ExpandablePageView.builder(
                        itemCount: controller.completedLoans.length +
                            (ownerHasReview ? 1 : 0),
                        onPageChanged: (value) {
                          controller.carouselIndex.value = value;
                        },
                        allowImplicitScrolling: true,
                        itemBuilder: (context, index) {
                          if (index == 0 && ownerHasReview) {
                            return _ownerReviewCard(controller);
                          }

                          return _reviewCard(
                              controller, index - (ownerHasReview ? 1 : 0));
                        },
                      ),
                    ),
                  ),
                  const Divider(),
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
                                        .withOpacity(0.25),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _informationTab(CommunitySpecificBookController controller) {
    return Builder(builder: (context) {
      final Color red = Theme.of(context).colorScheme.error;
      final Color purple = Theme.of(context).colorScheme.tertiary;
      const Color green = Color(0xFF7DAE6B);

      return Obx(
        () {
          if (controller.loading.value) {
            return SizedBox(
              height: 100,
              width: double.maxFinite,
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Theme.of(context).colorScheme.primary,
                size: 30,
              ),
            );
          }

          final Loan? currentLoan = controller.currentLoan.value;
          final Book book = controller.book;
          bool loanByCurrentUser = false;
          if (currentLoan != null) {
            loanByCurrentUser =
                currentLoan.loanee.id == UsersBackend.currentUserId;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(child: Text('owner'.tr)),
                        ),
                        const Divider(),
                        SizedBox(
                          height: 30,
                          child: Center(child: Text('added'.tr)),
                        ),
                        const Divider(),
                        SizedBox(
                          height: 30,
                          child: Center(child: Text('status'.tr)),
                        ),
                      ],
                    ),
                    const VerticalDivider(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                context.push(
                                  RouteNames.profileOtherPage
                                      .replaceFirst(':userId', book.owner.id),
                                );
                              },
                              child: Text(
                                book.owner.username,
                              ),
                            ),
                          ),
                        ),
                        const Divider(),
                        SizedBox(
                          height: 30,
                          child: Center(
                            child: Text(
                              DateFormat.yMMMd(Get.locale?.languageCode)
                                  .format(book.created_at),
                            ),
                          ),
                        ),
                        const Divider(),
                        Container(
                          height: 30,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: book.loaned
                                ? (loanByCurrentUser
                                    ? purple.withOpacity(0.25)
                                    : red.withOpacity(0.25))
                                : (loanByCurrentUser
                                    ? purple.withOpacity(0.25)
                                    : green.withOpacity(0.25)),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: book.loaned
                                      ? (loanByCurrentUser ? purple : red)
                                      : (loanByCurrentUser ? purple : green),
                                  shape: BoxShape.circle,
                                ),
                                height: 8,
                                width: 8,
                              ),
                              const VerticalDivider(width: 10),
                              Text(
                                book.loaned
                                    ? (loanByCurrentUser
                                        ? 'loaned'.tr
                                        : 'unavailable'.tr)
                                    : (loanByCurrentUser
                                        ? 'requested'.tr
                                        : 'available'.tr),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Visibility(
                  visible: !book.loaned && !loanByCurrentUser,
                  child: ElevatedButton(
                    onPressed: () => controller.requestLoan(context),
                    child: Text(
                      'request'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificBookController(bookId: bookId),
      builder: (CommunitySpecificBookController controller) {
        return Obx(() {
          if (controller.loading.value) return const CommonLoadingBody();

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.surface,
            ),
            body: DefaultTabController(
              length: 2,
              child: SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _bookTitle(controller.book),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(30),
                              child: Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(2, 1),
                                      blurRadius: 20,
                                      spreadRadius: 12,
                                      color: Color(0x4C3D3D3D),
                                    ),
                                  ],
                                ),
                                child: CommonBookCover(controller.book),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Theme.of(context).colorScheme.surfaceContainer,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DefaultTabController(
                            length: 2,
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                  child: TabBar(
                                    isScrollable: false,
                                    indicatorColor:
                                        Theme.of(context).colorScheme.primary,
                                    labelColor:
                                        Theme.of(context).colorScheme.primary,
                                    // overlayColor: Colors.blue,
                                    labelStyle: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16),
                                    unselectedLabelColor: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                    dividerColor: Colors.transparent,
                                    enableFeedback: true,
                                    tabs: [
                                      Text('information'.tr),
                                      Text('reviews'.tr),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children: [
                                      _informationTab(controller),
                                      _reviewsTab(controller),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
