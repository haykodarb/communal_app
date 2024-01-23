import 'package:communal/models/tool.dart';
import 'package:communal/presentation/common/common_item_card.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/presentation/community/community_specific/community_tools/community_tools_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityToolsPage extends StatelessWidget {
  const CommunityToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityToolsController(),
      builder: (controller) {
        return RefreshIndicator(
          onRefresh: controller.reloadPage,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Column(
              children: [
                PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
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
                Expanded(
                  child: Obx(
                    () => CommonLoadingBody(
                      loading: controller.firstLoad.value,
                      child: Obx(
                        () {
                          if (controller.toolsLoaded.isEmpty) {
                            return const CustomScrollView(
                              slivers: [
                                SliverFillRemaining(
                                  child: Center(
                                    child: Text(
                                      'No tools found.',
                                      style: TextStyle(fontSize: 14),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }

                          return ListView.separated(
                            itemCount: controller.toolsLoaded.length,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 20);
                            },
                            itemBuilder: (context, index) {
                              final Tool tool = controller.toolsLoaded[index];

                              return InkWell(
                                onTap: () {
                                  Get.toNamed(
                                    RouteNames.communitySpecificToolPage,
                                    arguments: {
                                      'tool': tool,
                                      'community': controller.community,
                                    },
                                  );
                                },
                                child: CommonItemCard(
                                  tool: tool,
                                  height: 200,
                                  children: [
                                    CommonTextInfo(label: 'Owner', text: tool.owner.username, size: 13),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
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
}
