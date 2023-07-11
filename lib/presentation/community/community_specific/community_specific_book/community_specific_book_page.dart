import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_card.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/community/community_specific/community_specific_book/community_specific_book_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommunitySpecificBookPage extends StatelessWidget {
  const CommunitySpecificBookPage({super.key});

  Widget _tableRow(String title, String text) {
    return Builder(
      builder: (context) {
        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
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
                      color: Theme.of(context).colorScheme.onBackground,
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
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 16,
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

  static const Widget _alreadyLoanedOutIndicator = Center(
    child: Text(
      'Book is currently\n loaned out.',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 20),
    ),
  );

  Widget _existingRequestByUser(CommunitySpecificBookController controller, Loan loan) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text(
          'Book loan has been requested.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
        Builder(
          builder: (context) {
            return Column(
              children: [
                Divider(color: Theme.of(context).colorScheme.primary),
                _tableRow(
                  'Requested',
                  DateFormat('HH:mm - d MMM y').format(loan.created_at),
                ),
                Divider(color: Theme.of(context).colorScheme.primary),
                _tableRow(
                  'Status',
                  loan.accepted ? 'Accepted' : 'Pending',
                ),
                const Divider(),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(
                        RouteNames.messagesSpecificPage,
                        arguments: {
                          'user': controller.book.owner,
                        },
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat),
                        VerticalDivider(),
                        Text('Chat'),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _bookAvailableForm(CommunitySpecificBookController controller) {
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

  Widget _loanInformation(CommunitySpecificBookController controller) {
    return Obx(
      () {
        final Loan? existingLoan = controller.existingLoan.value;

        if (existingLoan != null) {
          final bool loanedBySomeoneElse = existingLoan.loanee.id != UsersBackend.currentUserId;

          if (loanedBySomeoneElse) {
            return _alreadyLoanedOutIndicator;
          } else {
            return _existingRequestByUser(controller, existingLoan);
          }
        } else {
          return _bookAvailableForm(controller);
        }
      },
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
                  CommonBookCard(
                    book: controller.book,
                    textChildren: [
                      Text(controller.book.author),
                      Text(controller.book.owner.username),
                    ],
                  ),
                  const Divider(
                    height: 30,
                  ),
                  SizedBox(
                    height: 300,
                    child: Obx(
                      () => CommonLoadingBody(
                        loading: controller.loading.value,
                        child: _loanInformation(controller),
                      ),
                    ),
                  ),
                  const Divider(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Obx(
                      () {
                        return Text(
                          controller.message.value,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.error,
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
