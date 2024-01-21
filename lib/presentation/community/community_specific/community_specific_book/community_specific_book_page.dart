import 'package:carousel_slider/carousel_slider.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/presentation/common/common_username_button.dart';
import 'package:communal/presentation/community/community_specific/community_specific_book/community_specific_book_controller.dart';
import 'package:communal/routes.dart';
import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CommunitySpecificBookPage extends StatelessWidget {
  const CommunitySpecificBookPage({super.key});

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
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                book.author,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _ownerReview(CommunitySpecificBookController controller) {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextInfo(
                label: 'Owner\'s Review',
                text: controller.book.review ?? 'User has not reviewed this book yet.',
                size: 14,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reviewCard(CommunitySpecificBookController controller, int index) {
    final Loan loan = controller.completedLoans[index];
    return SizedBox(
      width: double.maxFinite,
      child: InkWell(
        onTap: () {
          controller.expandCarouselItem.value = !controller.expandCarouselItem.value;
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                Obx(
                  () => Text(
                    loan.review ?? '',
                    overflow: controller.expandCarouselItem.value ? TextOverflow.visible : TextOverflow.ellipsis,
                    maxLines: controller.expandCarouselItem.value ? null : 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _borrowersReviews(CommunitySpecificBookController controller) {
    return Builder(builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.maxFinite,
            child: Text(
              'Borrowers\' Reviews',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          Obx(
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

              if (controller.completedLoans.isEmpty) {
                return const Text('No other reviews available.');
              }

              return Column(
                children: [
                  const Divider(),
                  ExpandablePageView.builder(
                    itemCount: controller.completedLoans.length,
                    onPageChanged: (value) {
                      controller.carouselIndex.value = value;
                    },
                    itemBuilder: (context, index) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Align(
                            alignment: Alignment.topCenter,
                            child: _reviewCard(controller, index),
                          );
                        },
                      );
                    },
                  ),
                  const Divider(),
                  Visibility(
                    visible: controller.completedLoans.length > 1,
                    child: Container(
                      alignment: Alignment.center,
                      height: 10,
                      width: double.maxFinite,
                      child: ListView.builder(
                        itemCount: controller.completedLoans.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return Obx(
                            () => Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == controller.carouselIndex.value
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
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
          const Divider(),
        ],
      );
    });
  }

  Widget _sideInformation(CommunitySpecificBookController controller) {
    final Book book = controller.book;

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Owner',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.toNamed(
                        RouteNames.profileOtherPage,
                        arguments: {
                          'user': book.owner,
                        },
                      );
                    },
                    child: Text(book.owner.username),
                  ),
                  const Divider(),
                  CommonTextInfo(label: 'Added', text: DateFormat.yMMMd().format(book.created_at), size: 14),
                  const Divider(),
                  CommonTextInfo(label: 'Available', text: book.available ? 'Yes' : 'No', size: 14),
                  const Divider(),
                  Obx(
                    () {
                      if (controller.loading.value) {
                        return LoadingAnimationWidget.horizontalRotatingDots(
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        );
                      }

                      final Loan? currentLoan = controller.currentLoan.value;

                      if (currentLoan != null) {
                        final bool loanedByCurrentUser = currentLoan.loanee.id == UsersBackend.currentUserId;

                        if (!loanedByCurrentUser) {
                          return const SizedBox.shrink();
                        }

                        if (loanedByCurrentUser && currentLoan.accepted) {
                          return CommonTextInfo(
                            label: 'Status',
                            text: 'Borrowed ${DateFormat.yMMMd().format(currentLoan.accepted_at!)}',
                            size: 14,
                          );
                        }

                        if (loanedByCurrentUser) {
                          return CommonTextInfo(
                            label: 'Status',
                            text: 'Requested ${DateFormat.yMMMd().format(currentLoan.created_at)}',
                            size: 14,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      } else {
                        return MaterialButton(
                          onPressed: controller.requestLoan,
                          color: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.arrow_circle_down,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              const VerticalDivider(width: 5),
                              Text(
                                'Request',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificBookController(),
      builder: (CommunitySpecificBookController controller) {
        return Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _bookTitle(controller.book),
                    const Divider(height: 30),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: AspectRatio(
                              aspectRatio: 3 / 4,
                              child: FutureBuilder(
                                future: BooksBackend.getBookCover(controller.book),
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
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: _sideInformation(controller),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    _ownerReview(controller),
                    const Divider(height: 30),
                    _borrowersReviews(controller),
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
