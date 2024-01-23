import 'package:communal/models/tool.dart';
import 'package:communal/presentation/common/common_item_card.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/presentation/tool/tool_list_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ToolListPage extends StatelessWidget {
  const ToolListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ToolListController(),
      builder: (ToolListController controller) {
        return Scaffold(
          drawer: CommonDrawerWidget(),
          appBar: AppBar(
            elevation: 10,
            title: const Text('My Tools'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                ),
                child: TextField(
                  onChanged: controller.searchTools,
                  cursorColor: Theme.of(context).colorScheme.onBackground,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                    border: InputBorder.none,
                    errorBorder: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    focusedErrorBorder: InputBorder.none,
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                    ),
                    label: const Text(
                      'Search...',
                      textAlign: TextAlign.center,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: controller.goToAddToolPage,
            child: const Icon(
              Icons.add,
            ),
          ),
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              child: RefreshIndicator(
                onRefresh: controller.reloadTools,
                child: Obx(
                  () {
                    if (controller.userTools.isEmpty) {
                      return const Center(
                        child: Text(
                          'You haven\'t added\nany tools yet.',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    } else {
                      return ListView.separated(
                        itemCount: controller.userTools.length,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 20,
                          );
                        },
                        itemBuilder: (context, index) {
                          final Tool tool = controller.userTools[index];

                          return InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            onTap: () => Get.toNamed(
                              RouteNames.toolOwnedPage,
                              arguments: {
                                'tool': tool,
                                'controller': controller,
                              },
                            ),
                            child: CommonItemCard(
                              tool: tool,
                              height: 200,
                              children: [
                                CommonTextInfo(label: 'Available', text: tool.available ? 'Yes' : 'No', size: 13),
                              ],
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
