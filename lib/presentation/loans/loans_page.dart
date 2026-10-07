import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_filter_bottomsheet.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_loan_card.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/loans/loans_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoansController(),
      builder: (LoansController controller) {
        return DefaultTabController(
          length: 3,
          child: SafeArea(
            child: Scaffold(
              appBar: Responsive.isMobile(context)
                  ? AppBar(title: Text('Loans'.tr))
                  : null,
              drawer: Responsive.isMobile(context)
                  ? const CommonDrawerWidget()
                  : null,
              body: CustomScrollView(
                controller: controller.scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: Responsive.isMobile(context) ? 0 : 20,
                    ),
                  ),
                  SliverAppBar(
                    title: _searchRow(controller),
                    titleSpacing: 0,
                    stretch: true,
                    toolbarHeight: 55,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    floating: true,
                  ),
                  CommonListView<Loan>(
                    noItemsText:
                        'You have not loaned or borrowed any books yet.\n\nYou can get started by joining communities and searching their libraries for books you might enjoy.',
                    childBuilder: (Loan loan, _) => CommonKeepaliveWrapper(
                      child: CommonLoanCard(loan: loan),
                    ),
                    controller: controller.listViewController,
                    scrollController: controller.scrollController,
                    isSliver: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bottomSheet(LoansController controller) {
    LoansFilterParams filterParams = controller.filterParams.value;

    final int orderByIndex = filterParams.orderByDate ? 0 : 1;

    int filterByStateIndex = 0;

    if (filterParams.allStatus) {
      filterByStateIndex = 0;
    } else {
      if (filterParams.rejected) {
        filterByStateIndex = 4;
      } else {
        if (!filterParams.accepted) {
          filterByStateIndex = 1;
        } else if (!filterParams.returned) {
          filterByStateIndex = 2;
        } else {
          filterByStateIndex = 3;
        }
      }
    }

    int filterByOwnerIndex = 0;
    if (!filterParams.userIsLoanee && filterParams.userIsOwner) {
      filterByOwnerIndex = 1;
    }
    if (filterParams.userIsLoanee && !filterParams.userIsOwner) {
      filterByOwnerIndex = 2;
    }

    return CommonFilterBottomsheet(
      children: [
        CommonFilterRow(
          title: 'Order by'.tr,
          options: ['Date'.tr, 'Title'.tr],
          initialIndex: orderByIndex,
          onIndexChange: controller.onOrderByValueChanged,
        ),
        const Divider(height: 20),
        CommonFilterRow(
          title: 'Filter by status'.tr,
          options: [
            'All'.tr,
            'Pending'.tr,
            'Accepted'.tr,
            'Completed'.tr,
            'Rejected'.tr
          ],
          initialIndex: filterByStateIndex,
          onIndexChange: controller.onFilterByStatusChanged,
        ),
        const Divider(height: 20),
        CommonFilterRow(
          title: 'Filter by book ownership'.tr,
          options: ['All'.tr, 'Own'.tr, 'Foreign'.tr],
          initialIndex: filterByOwnerIndex,
          onIndexChange: controller.onFilterByOwnerChanged,
        ),
      ],
    );
  }

  Widget _searchRow(LoansController controller) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 10,
            right: 10,
            bottom: 2,
          ),
          child: CommonSearchBar(
            searchCallback: controller.onSearchTextChanged,
            filterCallback: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => _bottomSheet(controller),
              );
            },
            focusNode: FocusNode(),
          ),
        );
      },
    );
  }
}
