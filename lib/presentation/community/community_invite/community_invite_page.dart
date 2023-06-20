import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/community/community_invite/community_invite_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityInvitePage extends StatelessWidget {
  const CommunityInvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommunityInviteController>(
      init: CommunityInviteController(),
      builder: (CommunityInviteController controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            title: const Text('Invite user'),
            automaticallyImplyLeading: false,
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                  onChanged: controller.onQueryChanged,
                  onEditingComplete: controller.onSearch,
                  decoration: InputDecoration(
                    label: const Text('Search...'),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: IconButton(
                        onPressed: controller.onSearch,
                        icon: const Icon(
                          Icons.search,
                          size: 30,
                        ),
                      ),
                    ),
                    suffixIconColor: Get.theme.colorScheme.primary,
                  ),
                ),
                const Divider(height: 30),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Get.theme.colorScheme.primary),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: CommonLoadingBody(
                      loading: controller.loading,
                      child: ListView.builder(
                        itemCount: controller.foundProfiles.length,
                        itemBuilder: (context, index) {
                          return Obx(
                            () {
                              return TextButton(
                                onPressed: () => controller.onSelectedIndexChanged(index),
                                style: controller.selectedIndex.value == index
                                    ? TextButton.styleFrom(
                                        foregroundColor: Get.theme.colorScheme.onPrimary,
                                        backgroundColor: Get.theme.colorScheme.primary,
                                      )
                                    : TextButton.styleFrom(
                                        foregroundColor: Get.theme.colorScheme.onBackground,
                                        backgroundColor: Get.theme.colorScheme.background,
                                      ),
                                child: Text(
                                  controller.foundProfiles[index].username,
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const Divider(height: 15),
                SizedBox(
                  height: 70,
                  child: CommonLoadingBody(
                    loading: controller.processingInvite,
                    size: 40,
                    child: Obx(
                      () => Center(
                        child: Text(
                          controller.inviteError.value,
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(height: 15),
                ElevatedButton(
                  onPressed: controller.onSubmit,
                  child: const Text('Invite'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
