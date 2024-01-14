import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/presentation/community/community_specific/community_specific_book/community_specific_book_controller.dart';
import 'package:communal/routes.dart';
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

  Widget _bottomInformation(CommunitySpecificBookController controller) {
    return Builder(
      builder: (context) {
        return SizedBox(
          width: double.maxFinite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonTextInfo(
                label: 'Review',
                text: controller.book.review ?? 'Owner has not reviewed this book yet.',
                size: 14,
              ),
            ],
          ),
        );
      },
    );
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

                      if (!book.available) return const SizedBox.shrink();

                      final Loan? existingLoan = controller.existingLoan.value;

                      if (existingLoan != null) {
                        final bool loanedBySomeoneElse = existingLoan.loanee.id != UsersBackend.currentUserId;

                        if (!loanedBySomeoneElse) {
                          return CommonTextInfo(
                            label: 'Status',
                            text: 'Requested ${DateFormat.yMMMd().format(existingLoan.created_at)}',
                            size: 14,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      } else {
                        return TextButton(
                          onPressed: controller.requestLoan,
                          child: const Text('Request loan'),
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
                    _bottomInformation(controller),
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
