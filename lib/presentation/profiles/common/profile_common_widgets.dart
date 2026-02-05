import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ProfileCommonWidgets {
  static Widget bio(Profile profile) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About me'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Divider(height: 5),
              Text(
                profile.bio ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget loanCount() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '56 items borrowed',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '32 items lent',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget tabBar({
    required RxInt currentTabIndex,
    required Function(int) onTabTapped,
  }) {
    return Builder(
      builder: (BuildContext context) {
        final Color selectedBg = Theme.of(context).colorScheme.primary;
        final Color selectedFg = Theme.of(context).colorScheme.onPrimary;
        final Color unselectedBg =
            Theme.of(context).colorScheme.surfaceContainer;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(10),
            height: 70,
            width: double.maxFinite,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => onTabTapped(0),
                    child: Obx(
                      () {
                        return Container(
                          decoration: BoxDecoration(
                            color: currentTabIndex.value == 0
                                ? selectedBg
                                : unselectedBg,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Books'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: currentTabIndex.value == 0
                                  ? selectedFg
                                  : selectedBg,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => onTabTapped(1),
                    child: Obx(
                      () {
                        return Container(
                          decoration: BoxDecoration(
                            color: currentTabIndex.value == 1
                                ? selectedBg
                                : unselectedBg,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Reviews'.tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: currentTabIndex.value == 1
                                  ? selectedFg
                                  : selectedBg,
                            ),
                          ),
                        );
                      },
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

  static Widget reviewCard({
    required Loan loan,
    VoidCallback? onTap,
  }) {
    return Builder(
      builder: (context) {
        final card = Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loan.book.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                          const Divider(height: 5),
                          Text(
                            loan.book.author,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const Divider(height: 5),
                          Text(
                            '${DateFormat('MMM d, y', Get.locale?.languageCode).format(loan.latest_date!).capitalizeFirst}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.italic,
                              height: 1.2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 100,
                      child: CommonBookCover(
                        loan.book,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Text(
                  loan.review!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );

        if (onTap != null) {
          return InkWell(
            onTap: onTap,
            child: card,
          );
        }

        return card;
      },
    );
  }
}
