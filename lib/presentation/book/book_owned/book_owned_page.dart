import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_username_button.dart';
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

  Widget _ownerReviewCard(BookOwnedController controller) {
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
                      profile: controller.book.value.owner,
                      radius: 20,
                      clickable: true,
                    ),
                    const VerticalDivider(width: 10),
                    Text(
                      controller.book.value.owner.username,
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: () {
          controller.expandCarouselItem.value = !controller.expandCarouselItem.value;
        },
        child: Container(
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
  }

  Widget _reviewsTab(BookOwnedController controller) {
    return Builder(
      builder: (context) {
        return Center(
          child: Obx(
            () {
              bool ownerHasReview = controller.book.value.review != null && controller.book.value.review!.isNotEmpty;

              if (controller.completedLoans.isEmpty && !ownerHasReview) {
                return const Center(child: Text('No reviews.'));
              }

              return Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      itemCount: controller.completedLoans.length + (ownerHasReview ? 1 : 0),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (index == 0 && ownerHasReview) return _ownerReviewCard(controller);

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

                        return _reviewCard(controller, index - (ownerHasReview ? 1 : 0));
                      },
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

  Widget _buttonRow(BookOwnedController controller) {
    return Builder(
      builder: (context) {
        return Stack(
          children: [
            Visibility(
              visible: (!controller.book.value.loaned || !controller.book.value.public),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.editBook,
                      child: const Text('Edit'),
                    ),
                  ),
                  const VerticalDivider(),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.deleteBook,
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: controller.book.value.loaned,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('View loan'),
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
      init: BookOwnedController(),
      builder: (BookOwnedController controller) {
        return Scaffold(
          appBar: AppBar(),
          body: DefaultTabController(
            length: 2,
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 350 / 2,
                      ),
                      Expanded(
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
                        Container(
                          height: 325,
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Owner',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.fitWidth,
                                    child: Text(
                                      controller.book.value.owner.username,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Added',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('dd/MM/yy', Get.locale?.languageCode)
                                        .format(controller.book.value.created_at),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    controller.book.value.loaned ? 'Loaned' : 'Available',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 20),
                        Expanded(
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
  }
}
