import 'dart:async';

import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoansController extends GetxController {
  static const int pageSize = 12;

  Rx<LoansFilterParams> filterParams = LoansFilterParams().obs;

  Timer? debounceTimer;

  final ScrollController scrollController = ScrollController();

  final CommonListViewController<Loan> listViewController = CommonListViewController(pageSize: pageSize);

  RxBool firstLoad = true.obs;

  @override
  void onInit() {
    listViewController.registerNewPageCallback(loadLoans);

    filterParams.listen(
      (LoansFilterParams params) {
        debounceTimer?.cancel();

        debounceTimer = Timer(
          const Duration(milliseconds: 500),
          () async => await listViewController.reloadList(),
        );
      },
    );

    super.onInit();
  }

  void removeItemById(String id) {
    listViewController.itemList.removeWhere((element) => element.id == id);
    listViewController.itemList.refresh();
    listViewController.pageKey--;
  }

  void onSearchTextChanged(String value) {
    filterParams.value.searchQuery = value;
    filterParams.refresh();
  }

  void onOrderByValueChanged(int index) {
    filterParams.value.orderByDate = index == 0;
    filterParams.refresh();
  }

  void onFilterByOwnerChanged(int index) {
    switch (index) {
      case 0:
        filterParams.value.userIsLoanee = true;
        filterParams.value.userIsOwner = true;
        break;

      case 1:
        filterParams.value.userIsLoanee = false;
        filterParams.value.userIsOwner = true;
        break;

      case 2:
        filterParams.value.userIsLoanee = true;
        filterParams.value.userIsOwner = false;
        break;
      default:
        break;
    }

    filterParams.refresh();
  }

  void onFilterByStatusChanged(int index) {
    switch (index) {
      case 0:
        filterParams.value.allStatus = true;
        filterParams.value.accepted = false;
        filterParams.value.returned = false;
        filterParams.value.rejected = false;
        break;
      case 1:
        filterParams.value.allStatus = false;
        filterParams.value.accepted = false;
        filterParams.value.returned = false;
        filterParams.value.rejected = false;
        break;
      case 2:
        filterParams.value.allStatus = false;
        filterParams.value.accepted = true;
        filterParams.value.returned = false;
        filterParams.value.rejected = false;
        break;
      case 3:
        filterParams.value.allStatus = false;
        filterParams.value.accepted = true;
        filterParams.value.returned = true;
        filterParams.value.rejected = false;
        break;
      case 4:
        filterParams.value.allStatus = false;
        filterParams.value.accepted = false;
        filterParams.value.returned = false;
        filterParams.value.rejected = true;
        break;
      default:
        break;
    }

    filterParams.refresh();
  }

  Future<List<Loan>> loadLoans(int pageKey) async {
    final BackendResponse response = await LoansBackend.getLoansForUser(filterParams.value, pageKey, pageSize);

    if (response.success) {
      return response.payload;
    }

    return [];
  }
}
