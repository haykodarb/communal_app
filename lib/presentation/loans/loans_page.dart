import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_book_cover.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_filter_bottomsheet.dart';
import 'package:communal/presentation/common/common_keepalive_wrapper.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/loans/loans_controller.dart';
import 'package:communal/responsive.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class LoansPage extends StatelessWidget {
  const LoansPage({super.key});

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
          title: 'Ordenar por',
          options: const ['Fecha', 'Titulo'],
          initialIndex: orderByIndex,
          onIndexChange: controller.onOrderByValueChanged,
        ),
        const Divider(height: 20),
        CommonFilterRow(
          title: 'Filtrar por estado',
          options: const ['Todos', 'Pendiente', 'Aceptado', 'Finalizado', 'Rechazado'],
          initialIndex: filterByStateIndex,
          onIndexChange: controller.onFilterByStatusChanged,
        ),
        const Divider(height: 20),
        CommonFilterRow(
          title: 'Filtrar por propiedad del libro',
          options: const ['Todos', 'Propio', 'Ajeno'],
          initialIndex: filterByOwnerIndex,
          onIndexChange: controller.onFilterByOwnerChanged,
        ),
      ],
    );
  }

  Widget _loanCard(Loan loan, LoansController controller) {
    return Builder(
      builder: (context) {
        return InkWell(
          overlayColor: WidgetStateColor.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            context.push('${RouteNames.loansPage}/${loan.id}');
          },
          child: Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              height: 160,
              padding: const EdgeInsets.all(20),
              child: Row(
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                        const Divider(height: 5),
                        Text(
                          loan.book.author,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Expanded(child: Divider(height: 5)),
                        Row(
                          children: [
                            Text(
                              loan.loanee.isCurrentUser ? loan.book.owner.username : loan.loanee.username,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                            const VerticalDivider(width: 5),
                            Container(
                              decoration: BoxDecoration(
                                color: loan.loanee.isCurrentUser
                                    ? Theme.of(context).colorScheme.tertiary.withOpacity(0.25)
                                    : Theme.of(context).colorScheme.primary.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                              child: Text(
                                loan.loanee.isCurrentUser ? 'Owner' : 'Loanee',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 5),
                        Text(
                          loan.returned
                              ? 'Loan finished'
                              : loan.accepted
                                  ? 'Loan accepted'
                                  : loan.rejected
                                      ? 'Loan rejected'
                                      : 'Awaiting approval',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Divider(height: 5),
                        Text(
                          '${loan.returned ? 'Returned' : loan.accepted ? 'Approved' : loan.rejected ? 'Rejected' : 'Requested'}${DateFormat(' MMMM d, y', Get.locale?.languageCode).format(loan.latest_date ?? loan.created_at)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: CommonBookCover(loan.book),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _searchRow(LoansController controller) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 2),
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoansController(),
      builder: (LoansController controller) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Loans'),
            ),
            drawer: Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
            body: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                SliverAppBar(
                  title: _searchRow(controller),
                  titleSpacing: 0,
                  toolbarHeight: 55,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  floating: true,
                ),
                CommonListView<Loan>(
                  childBuilder: (Loan loan) => CommonKeepaliveWrapper(child: _loanCard(loan, controller)),
                  controller: controller.listViewController,
                  scrollController: controller.scrollController,
                  isSliver: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
