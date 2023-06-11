import 'package:communal/backend/books_backend.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/community/community_specific/community_specific_book/community_specific_book_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommunitySpecificBookPage extends StatelessWidget {
  const CommunitySpecificBookPage({super.key});

  Widget _bookCard(CommunitySpecificBookController controller) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        height: 200,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4,
              child: SizedBox(
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
            const VerticalDivider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.book.title,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const Divider(),
                    Text(controller.book.author),
                    const Divider(),
                    Text(controller.book.owner.username),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _tableRow(String title, String text) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.background,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                title,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: Get.theme.colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
            ),
            const VerticalDivider(width: 20),
            Expanded(
              flex: 3,
              child: Text(
                text,
                style: TextStyle(
                  color: Get.theme.colorScheme.onBackground,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loanInformation(CommunitySpecificBookController controller) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Get.theme.colorScheme.primary,
          width: 0.5,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.maxFinite,
      height: 300,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Obx(
        () {
          return CommonLoadingBody(
            isLoading: controller.book.loading.value,
            child: Obx(
              () {
                if (controller.existingLoan.value == null) {
                  return Padding(
                    padding: const EdgeInsets.all(60),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Book is available',
                          style: TextStyle(fontSize: 20),
                        ),
                        const Divider(height: 50),
                        ElevatedButton(
                          onPressed: controller.requestLoan,
                          child: const Text('Request'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Text(
                      'Book loan has been requested.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                    Column(
                      children: [
                        Divider(color: Get.theme.colorScheme.primary),
                        _tableRow(
                          'Requested',
                          DateFormat('HH:m - d MMM y').format(controller.existingLoan.value!.created_at),
                        ),
                        Divider(color: Get.theme.colorScheme.primary),
                        _tableRow(
                          'Status',
                          controller.existingLoan.value!.accepted ? 'Accepted' : 'Pending',
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunitySpecificBookController(),
      builder: (CommunitySpecificBookController controller) {
        return Scaffold(
          appBar: AppBar(
            title: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(controller.book.title),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _bookCard(controller),
                  const Divider(
                    height: 30,
                  ),
                  _loanInformation(controller),
                  const Divider(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: Text(
                      'Chat',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Obx(
                      () {
                        return Text(
                          controller.message.value,
                          style: TextStyle(
                            fontSize: 16,
                            color: Get.theme.colorScheme.error,
                          ),
                          textAlign: TextAlign.justify,
                        );
                      },
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
