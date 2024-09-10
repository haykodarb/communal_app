import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/community.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/community/community_list_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityListPage extends StatelessWidget {
  const CommunityListPage({super.key});

  Widget _communityCard(
    CommunityListController controller,
    Community community,
  ) {
    return Builder(builder: (context) {
      return Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            InkWell(
              onTap: () => controller.goToCommunitySpecific(community),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: FutureBuilder(
                      future: CommunitiesBackend.getCommunityAvatar(community),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.active ||
                            snapshot.connectionState ==
                                ConnectionState.waiting) {
                          return const CommonLoadingImage();
                        }

                        if (snapshot.data == null) {
                          return Container(
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.75),
                            child: Icon(
                              Atlas.users,
                              color: Theme.of(context).colorScheme.surface,
                              size: 150,
                            ),
                          );
                        }

                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    height: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                community.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              child: Text(
                                "${community.user_count} members",
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                community.description ?? 'No description.',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Obx(
                      () => Icon(
                        Atlas.pin,
                        size: 20,
                        color: community.pinned.value
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityListController(),
      builder: (controller) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: controller.goToCommunityCreate,
            child: const Icon(
              Icons.add,
              size: 35,
            ),
          ),
          appBar: AppBar(
            title: const Text('Communities'),
          ),
          drawer: CommonDrawerWidget(),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
	    crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Obx(
                  () => CommonLoadingBody(
                    loading: controller.loading.value,
                    child: Center(
                      child: SizedBox(
                        width: 600,
                        child: Obx(
                          () {
                            if (controller.communities.isNotEmpty) {
                              return ListView.separated(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  right: 20,
                                  left: 20,
                                  bottom: 90,
                                ),
                                itemCount: controller.communities.length,
                                separatorBuilder: (context, index) =>
                                    const Divider(height: 10),
                                itemBuilder: (context, index) {
                                  return _communityCard(
                                    controller,
                                    controller.communities[index],
                                  );
                                },
                              );
                            } else {
                              return const CustomScrollView(
                                slivers: [
                                  SliverFillRemaining(
                                    child: Center(
                                      child: Text(
                                        'You have not joined\nany communities yet.',
                                        style: TextStyle(fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
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
}
