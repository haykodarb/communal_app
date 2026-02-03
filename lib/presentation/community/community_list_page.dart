import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_community_card.dart';
import 'package:communal/presentation/common/common_list_view.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/community/community_list_controller.dart';
import 'package:communal/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityListPage extends StatelessWidget {
  const CommunityListPage({super.key});

  Widget _communityCard(
    CommunityListController controller,
    Community community,
  ) {
    return Builder(
      builder: (context) {
        return Stack(
          children: [
            CommonCommunityCard(
              community: community,
              callback: () =>
                  controller.goToCommunitySpecific(community, context),
            ),
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => controller.toggleCommunityPinnedValue(community),
                child: Obx(() {
                  return Container(
                    height: 40,
                    width: 40,
                    margin: const EdgeInsets.only(top: 10, right: 10),
                    decoration: BoxDecoration(
                      color: community.pinned.value
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Obx(
                      () => Icon(
                        Atlas.pin,
                        size: 20,
                        color: community.pinned.value
                            ? Theme.of(context).colorScheme.surfaceContainer
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityListController(),
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => controller.goToCommunityCreate(context),
            child: const Icon(
              Icons.add,
              size: 35,
            ),
          ),
          appBar: Responsive.isMobile(context)
              ? AppBar(title: Text('Communities'.tr))
              : null,
          drawer:
              Responsive.isMobile(context) ? const CommonDrawerWidget() : null,
          drawerEnableOpenDragGesture: false,
          body: CommonListView(
            noItemsText: 'community-list-no-items'.tr,
            childBuilder: (Community community) => _communityCard(
              controller,
              community,
            ),
            controller: controller.listViewController,
          ),
        );
      },
    );
  }
}
