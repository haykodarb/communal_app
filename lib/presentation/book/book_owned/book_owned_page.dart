import 'package:communal/models/book.dart';
import 'package:communal/presentation/book/book_detail_view.dart';
import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
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
          () {
            if (controller.firstLoad.value) return const CommonLoadingBody();

            final Book book = controller.book.value;

            return BookDetailView(
              key: ValueKey(book.id),
              book: book,
              expandCoverOnTap: true,
              info: [
                BookInfoItem(
                  'Added'.tr,
                  Text(
                    DateFormat('dd/MM/yy', Get.locale?.languageCode)
                        .format(book.created_at),
                  ),
                ),
                BookInfoItem(
                  'Visibility'.tr,
                  Text(book.public ? 'Public'.tr : 'Private'.tr),
                ),
                BookInfoItem(
                  'Status'.tr,
                  Text(book.loaned ? 'Loaned'.tr : 'Available'.tr),
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
