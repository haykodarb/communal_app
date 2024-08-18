import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class BookOwnedPage extends StatelessWidget {
  const BookOwnedPage({super.key});

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
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
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

  Widget _ownerReviewCard(BookOwnedController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          controller.expandCarouselItem.value = !controller.expandCarouselItem.value;
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(Get.context!).colorScheme.surface,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CommonCircularAvatar(
                    profile: controller.book.value.owner,
                    radius: 20,
                    clickable: true,
                  ),
                  const VerticalDivider(width: 10),
                  Text(
                    'Your review',
                    style: TextStyle(
                      color: Theme.of(Get.context!).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(),
              SingleChildScrollView(
                child: Obx(
                  () => Text(
                    controller.book.value.review ?? '',
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
  }

  Widget _reviewCard(BookOwnedController controller, int index) {
    final Loan loan = controller.completedLoans[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          controller.expandCarouselItem.value = !controller.expandCarouselItem.value;
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(Get.context!).colorScheme.surfaceContainer,
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
  }

  Widget _reviewsTab(BookOwnedController controller) {
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

              bool ownerHasReview = controller.book.value.review != null && controller.book.value.review!.isNotEmpty;

              if (controller.completedLoans.isEmpty && !ownerHasReview) {
                return const Center(child: Text('No reviews.'));
              }

              return Column(
                children: [
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: ExpandablePageView.builder(
                        itemCount: controller.completedLoans.length + (ownerHasReview ? 1 : 0),
                        onPageChanged: (value) {
                          controller.carouselIndex.value = value;
                        },
                        allowImplicitScrolling: true,
                        itemBuilder: (context, index) {
                          if (index == 0 && ownerHasReview) return _ownerReviewCard(controller);

                          return _reviewCard(controller, index - (ownerHasReview ? 1 : 0));
                        },
                      ),
                    ),
                  ),
                  const Divider(),
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
                  const Divider(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _informationTab(BookOwnedController controller) {
    final BuildContext context = Get.context!;
    final Color purple = Theme.of(context).colorScheme.tertiary;
    const Color green = Color(0xFF7DAE6B);

    final Book book = controller.book.value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Expanded(child: SizedBox()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                      child: Text('added'.tr),
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 30,
                      child: Text('Visibility'),
                    ),
                    const Divider(),
                    SizedBox(
                      height: 30,
                      child: Text('status'.tr),
                    ),
                  ],
                ),
              ),
              const VerticalDivider(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                      child: Text(
                        DateFormat.yMMMd(Get.locale?.languageCode).format(book.created_at),
                      ),
                    ),
                    const Divider(),
                    SizedBox(
                      height: 30,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            book.public ? Atlas.unlock_keyhole : Atlas.lock_keyhole,
                            size: 14,
                          ),
                          const VerticalDivider(width: 5),
                          Text(book.public ? 'Public' : 'Private'),
                        ],
                      ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Container(
                          constraints: const BoxConstraints.tightFor(height: 30),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: (!book.loaned || !book.public) ? green.withOpacity(0.25) : purple.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: (!book.loaned || !book.public) ? green : purple,
                                  shape: BoxShape.circle,
                                ),
                                height: 8,
                                width: 8,
                              ),
                              const VerticalDivider(width: 10),
                              Text(
                                (!book.loaned || !book.public) ? 'available'.tr : 'loaned'.tr,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Expanded(child: SizedBox()),
          Visibility(
            visible: (!book.loaned || !book.public),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.editBook,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Edit'),
                        VerticalDivider(width: 5),
                        Icon(
                          Atlas.pencil,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.deleteBook,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Delete'),
                        VerticalDivider(width: 5),
                        Icon(
                          Atlas.trash,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Visibility(
            visible: book.loaned,
            child: ElevatedButton(
              onPressed: () {},
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View loan',
                  ),
                  VerticalDivider(width: 10),
                  Icon(
                    Atlas.account_arrows,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BookOwnedController(),
      builder: (BookOwnedController controller) {
        return Scaffold(
          appBar: AppBar(),
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
                        Obx(() => _bookTitle(controller.book.value)),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
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
                              child: CommonBookCover(controller.book.value),
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
                                  indicatorColor: Theme.of(context).colorScheme.primary,
                                  labelColor: Theme.of(context).colorScheme.primary,
                                  // overlayColor: Colors.blue,
                                  labelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
                                  unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  children: [
                                    Obx(
                                      () => _informationTab(controller),
                                    ),
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
      },
    );
  }
}
