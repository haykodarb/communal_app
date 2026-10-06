import 'package:communal/models/book.dart';
import 'package:communal/models/profile.dart';
import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/common/common_button.dart';
import 'package:communal/presentation/common/common_filter_bottomsheet.dart';
import 'package:communal/presentation/common/common_pill_button.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/common/common_user_card.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_search_bar.dart';
import 'package:communal/presentation/common/common_tab_bar.dart';
import 'package:communal/presentation/common/common_vertical_book_card.dart';
import 'package:communal/presentation/search/search_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  String _note(Book book) {
    return [
      if (book.viaUsername != null)
        'via {name}'.tr.replaceFirst('{name}', book.viaUsername!),
      if ((book.owner.location ?? '').isNotEmpty) book.owner.location!,
    ].join(' · ');
  }

  Widget _locationSheet(SearchPageController controller) {
    String draft = controller.location.value;

    return Builder(
      builder: (context) {
        void apply(String value) {
          controller.onLocationChanged(value);
          Navigator.of(context).pop();
        }

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: CommonFilterBottomsheet(
            children: [
              CommonTextField(
                label: 'Location (neighbourhood or city)'.tr,
                initialValue: draft,
                validator: (_) => null,
                callback: (value) => draft = value,
                submitCallback: apply,
              ),
              const Divider(height: 20),
              SizedBox(
                width: double.maxFinite,
                child: CommonButton(
                  onPressed: (_) => apply(draft),
                  child: Text('Apply'.tr),
                ),
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
      init: SearchPageController(),
      builder: (SearchPageController controller) {
        return Scaffold(
          appBar: Responsive.isMobile(context)
              ? AppBar(title: Text('Search'.tr))
              : null,
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          body: SafeArea(
            child: CustomScrollView(
              controller: controller.scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: Responsive.isMobile(context) ? 0 : 20,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: CommonTabBar(
                      onTabTapped: controller.onTabTapped,
                      currentIndex: controller.currentTabIndex,
                      tabs: [
                        'Books'.tr,
                        'Users'.tr,
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 5)),
                SliverAppBar(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Obx(
                      () => CommonSearchBar(
                        searchCallback: controller.onQueryChanged,
                        focusNode: FocusNode(),
                        filterCallback: controller.currentTabIndex.value == 0
                            ? () => showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) =>
                                      _locationSheet(controller),
                                )
                            : null,
                      ),
                    ),
                  ),
                  titleSpacing: 0,
                  toolbarHeight: 60,
                  centerTitle: true,
                  automaticallyImplyLeading: false,
                  pinned: true,
                ),
                Obx(
                  () {
                    if (controller.currentTabIndex.value != 0 ||
                        controller.location.value.isEmpty) {
                      return const SliverToBoxAdapter(child: SizedBox.shrink());
                    }

                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15, top: 5),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: CommonPillButton(
                            icon: Atlas.pin_destination,
                            label: '${controller.location.value}  ✕',
                            onPressed: (_) => controller.onLocationChanged(''),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 5)),
                Obx(
                  () {
                    switch (controller.currentTabIndex.value) {
                      case 0:
                        return CommonGridView<Book>(
                          padding: const EdgeInsets.only(
                            bottom: 20,
                            left: 10,
                            right: 10,
                          ),
                          isSliver: true,
                          scrollController: controller.scrollController,
                          childBuilder: (Book book) => CommonVerticalBookCard(
                            book: book,
                            note: _note(book),
                          ),
                          noItemsText:
                              'No books found among your friends and their friends.'
                                  .tr,
                          controller: controller.bookListController,
                        );
                      case 1:
                        return CommonListView<Profile>(
                          padding: const EdgeInsets.only(
                            bottom: 20,
                            left: 10,
                            right: 10,
                          ),
                          isSliver: true,
                          scrollController: controller.scrollController,
                          childBuilder: (Profile profile, _) =>
                              CommonUserCard(
                            profile: profile,
                            subtitle: profile.location,
                          ),
                          controller: controller.profileListController,
                          noItemsText:
                              'No users found, likely a network issue.',
                        );
                      default:
                        return const SizedBox.shrink();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
