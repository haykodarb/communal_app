import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_loan_card.dart';
import 'package:communal/presentation/common/common_review_card.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/home/home_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:communal/presentation/common/common_empty_state.dart';
import 'package:atlas_icons/atlas_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

/// What's going on around you: the books that are out right now, what your
/// friends have been reviewing and what your network added lately. Things to
/// act on (requests, available books) are in Notifications. The first two
/// sections hide themselves when empty; the network grid, last, loads more as
/// you scroll.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const EdgeInsets _sectionPadding =
      EdgeInsets.symmetric(horizontal: 15);

  Widget _heading(String title, {String? seeAllRoute}) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 24, 15, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (seeAllRoute != null)
                InkWell(
                  onTap: () => context.push(seeAllRoute),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: Text(
                      'See all'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _cardList(List<Widget> cards) {
    return SliverPadding(
      padding: _sectionPadding,
      sliver: SliverList.separated(
        itemCount: cards.length,
        itemBuilder: (context, index) => cards[index],
        separatorBuilder: (context, index) => const SizedBox(height: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: HomeController(),
      builder: (HomeController controller) {
        return Scaffold(
          appBar: Responsive.isMobile(context)
              ? AppBar(title: Text('Home'.tr))
              : null,
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          body: SafeArea(
            child: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: Responsive.isMobile(context) ? 0 : 10,
                  ),
                ),
                Obx(
                  () {
                    if (controller.activeLoans.isEmpty) {
                      return const SliverToBoxAdapter();
                    }

                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _heading(
                            'On loan'.tr,
                            seeAllRoute: RouteNames.loansPage,
                          ),
                        ),
                        _cardList(
                          controller.activeLoans
                              .take(HomeController.loansPreview)
                              .map((loan) => CommonLoanCard(loan: loan))
                              .toList(),
                        ),
                      ],
                    );
                  },
                ),
                Obx(
                  () {
                    if (controller.reviews.isEmpty) {
                      return const SliverToBoxAdapter();
                    }

                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: _heading(
                            'Recent reviews from friends'.tr,
                            seeAllRoute: RouteNames.reviewsPage,
                          ),
                        ),
                        _cardList(
                          controller.reviews
                              .take(HomeController.reviewsPreview)
                              .map(
                                (loan) => CommonReviewCard(
                                  loan: loan,
                                  showReviewer: true,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: _heading('New in your network'.tr),
                ),
                CommonGridView<Book>(
                  padding: const EdgeInsets.only(
                    bottom: 40,
                    left: 10,
                    right: 10,
                  ),
                  maxColumns: 3,
                  isSliver: true,
                  scrollController: controller.scrollController,
                  childBuilder: (Book book) => CommonVerticalBookCard(
                    book: book,
                  ),
                  noItemsText:
                      'No books from your friends yet.\nFind people you know in Search.'
                          .tr,
                  emptyState: () => CommonEmptyState(
                    icon: Atlas.book,
                    title:
                        'No books from your friends yet.\nFind people you know in Search.'
                            .tr,
                    actionLabel: 'Search'.tr,
                    actionIcon: Atlas.magnifying_glass,
                    onAction: (context) =>
                        context.go(RouteNames.searchPage, extra: 1),
                  ),
                  controller: controller.networkListController,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
