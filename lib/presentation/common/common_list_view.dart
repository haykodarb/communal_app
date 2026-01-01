import 'dart:async';

import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonListViewController<ItemType> extends GetxController {
  CommonListViewController({
    required this.pageSize,
  });

  final RxList<ItemType> itemList = <ItemType>[].obs;
  final RxBool firstLoad = true.obs;
  final RxBool showLoadingMore = false.obs;
  bool loadingMore = false;

  bool fullyLoaded = false;

  Timer? debounceTimer;
  final int pageSize;
  int pageKey = 0;

  Future<List<ItemType>> Function(int pageKey)? newPageCallback;

  ScrollController? scrollController;

  final RxInt scrollPosition = 0.obs;

  Future<void> registerNewPageCallback(
    Future<List<ItemType>> Function(int pageKey) callback,
  ) async {
    newPageCallback = callback;

    firstLoad.value = true;

    final List<ItemType> newItems = await newPageCallback!(pageKey);

    pageKey += newItems.length;
    itemList.addAll(newItems);
    itemList.refresh();

    if (newItems.length < pageSize) {
      fullyLoaded = true;
    }

    firstLoad.value = false;
  }

  void addItem(ItemType item) {
    itemList.add(item);
    itemList.refresh();
    pageKey++;
  }

  void removeItem(bool Function(ItemType) callback) {
    itemList.removeWhere(callback);
    itemList.refresh();
    pageKey--;
  }

  Future<void> reloadList() async {
    // Already loading first page (probably from "registerNewPageCallback";
    if (firstLoad.value) return;

    itemList.clear();
    fullyLoaded = false;
    pageKey = 0;

    firstLoad.value = true;

    final List<ItemType> newItems = await newPageCallback!(pageKey);

    pageKey += newItems.length;
    itemList.addAll(newItems);
    itemList.refresh();

    firstLoad.value = false;
  }

  void registerScrollController(ScrollController newScrollController) {
    scrollController = newScrollController;
    scrollController?.addListener(scrollListener);
    print('controller added');
  }

  @override
  void onClose() {
    scrollController?.removeListener(scrollListener);
    super.onClose();
  }

  Future<void> scrollListener() async {
    scrollPosition.value = scrollController?.position.pixels.toInt() ?? 0;

    if (scrollController!.position.maxScrollExtent -
            scrollController!.position.pixels <
        200) {
      if (loadingMore) return;
      if (fullyLoaded) return;
      if (newPageCallback == null) return;

      showLoadingMore.value = true;
      loadingMore = true;

      final List<ItemType> newItems = await newPageCallback!(pageKey);

      pageKey += newItems.length;
      itemList.addAll(newItems);
      itemList.refresh();

      if (newItems.length < pageSize) {
        fullyLoaded = true;
      }

      showLoadingMore.value = false;

      debounceTimer = Timer(
        const Duration(milliseconds: 500),
        () {
          loadingMore = false;
        },
      );
    }
  }
}

class CommonGridView<ItemType> extends StatelessWidget {
  const CommonGridView({
    required this.childBuilder,
    required this.controller,
    this.scrollPhysics = const AlwaysScrollableScrollPhysics(),
    this.padding = const EdgeInsets.all(10),
    this.horizontalSeparator = const Divider(height: 5),
    this.verticalSeparator = const VerticalDivider(width: 5),
    this.isSliver = false,
    this.scrollController,
    this.noItemsText = 'No items.',
    super.key,
  });

  final Widget Function(ItemType) childBuilder;
  final Widget verticalSeparator;
  final Widget horizontalSeparator;
  final EdgeInsets padding;
  final CommonListViewController controller;
  final ScrollPhysics scrollPhysics;
  final bool isSliver;
  final ScrollController? scrollController;
  final String noItemsText;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: controller,
      initState: (state) {
        controller
            .registerScrollController(scrollController ?? ScrollController());
      },
      builder: (_) {
        return Obx(
          () {
            if (controller.firstLoad.value) {
              if (isSliver) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: false,
                  child: CommonLoadingBody(),
                );
              }

              return const CommonLoadingBody();
            }

            if (controller.itemList.isEmpty) {
              if (isSliver) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: false,
                  child: Center(
                    child: SizedBox(
                      width: 300,
                      child: Text(
                        noItemsText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              }

              return Center(
                child: SizedBox(
                  width: 300,
                  child: Text(
                    noItemsText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            }

            final List<Widget> firstColumnChildren = [];
            final List<Widget> secondColumnChildren = [];

            for (int i = 0; i < controller.itemList.length; i++) {
              final ItemType item = controller.itemList[i];

              if (i % 2 == 0) {
                firstColumnChildren.add(childBuilder(item));
                firstColumnChildren.add(horizontalSeparator);
              } else {
                secondColumnChildren.add(childBuilder(item));
                secondColumnChildren.add(horizontalSeparator);
              }
            }

            final List<Widget> mainColumnChildren = [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: firstColumnChildren,
                    ),
                  ),
                  verticalSeparator,
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: secondColumnChildren,
                    ),
                  ),
                ],
              ),
            ];

            if (controller.showLoadingMore.value) {
              mainColumnChildren.add(horizontalSeparator);
              mainColumnChildren.add(horizontalSeparator);
              mainColumnChildren.add(const CommonLoadingBody(size: 30));
            }

            final Widget masonry = Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: mainColumnChildren,
              ),
            );

            if (isSliver) {
              return SliverToBoxAdapter(
                child: masonry,
              );
            }

            return SingleChildScrollView(child: masonry);
          },
        );
      },
    );
  }
}

class CommonListView<ItemType> extends StatelessWidget {
  const CommonListView({
    required this.childBuilder,
    required this.controller,
    this.axis = Axis.vertical,
    this.scrollPhysics = const AlwaysScrollableScrollPhysics(),
    this.padding = const EdgeInsets.all(10),
    this.separator = const Divider(height: 5),
    this.isSliver = false,
    this.scrollController,
    this.noItemsText = 'No items.',
    super.key,
  });

  final Widget Function(ItemType) childBuilder;
  final Widget separator;
  final EdgeInsets padding;
  final CommonListViewController controller;
  final ScrollPhysics scrollPhysics;
  final bool isSliver;
  final ScrollController? scrollController;

  final Axis axis;
  final String noItemsText;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: controller,
        initState: (state) {
          controller
              .registerScrollController(scrollController ?? ScrollController());
        },
        builder: (_) {
          return Obx(
            () {
              if (controller.firstLoad.value) {
                if (isSliver) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: false,
                    child: CommonLoadingBody(),
                  );
                }

                return const CommonLoadingBody();
              }

              if (controller.itemList.isEmpty) {
                if (isSliver) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    fillOverscroll: false,
                    child: Center(
                      child: SizedBox(
                        width: 300,
                        child: Text(
                          noItemsText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  );
                }

                return Center(
                  child: SizedBox(
                    width: 300,
                    child: Text(
                      noItemsText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              final List<Widget> widgets = List.generate(
                controller.itemList.length * 2 - 1,
                (int index) {
                  if (index % 2 == 0) {
                    return childBuilder(
                      controller.itemList[(index / 2).floor()],
                    );
                  }

                  return separator;
                },
                growable: true,
              );

              if (controller.showLoadingMore.value) {
                widgets.add(separator);
                widgets.add(separator);
                widgets.add(const CommonLoadingBody(size: 30));
              }

              if (isSliver) {
                return SliverPadding(
                  padding: padding,
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(widgets),
                  ),
                );
              }

              return Stack(
                children: [
                  ListView(
                    padding: padding,
                    controller: controller.scrollController,
                    physics: scrollPhysics,
                    scrollDirection: axis,
                    children: widgets,
                  ),
                  Obx(
                    () {
                      final int position = controller.scrollPosition.value;
                      return Visibility(
                        visible: axis == Axis.horizontal && position != 0,
                        child: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            onPressed: () {
                              controller.scrollController!.animateTo(
                                controller.scrollController!.position.pixels -
                                    400,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.linear,
                              );
                            },
                            style: IconButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary),
                            icon: Icon(
                              Icons.chevron_left,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 40,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Obx(
                    () {
                      final int position = controller.scrollPosition.value;

                      final int maxScrollExtent =
                          (controller.scrollController?.hasClients ?? false)
                              ? (controller.scrollController!.position
                                      .hasContentDimensions
                                  ? controller.scrollController!.position
                                      .maxScrollExtent
                                      .toInt()
                                  : 0)
                              : 0;

                      return Visibility(
                        visible: axis == Axis.horizontal &&
                            position != maxScrollExtent,
                        child: Container(
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            onPressed: () {
                              controller.scrollController!.animateTo(
                                controller.scrollController!.position.pixels +
                                    400,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.linear,
                              );
                            },
                            style: IconButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary),
                            icon: Icon(
                              Icons.chevron_right,
                              color: Theme.of(context).colorScheme.onPrimary,
                              size: 40,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          );
        });
  }
}
