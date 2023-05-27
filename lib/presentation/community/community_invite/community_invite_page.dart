import 'package:biblioteca/presentation/community/community_invite/community_invite_controller.dart';
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
          appBar: AppBar(title: const Text('Invite user')),
          body: Padding(
            padding: const EdgeInsets.all(30),
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(color: Get.theme.colorScheme.primary),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Obx(
                      () {
                        if (controller.loading.value) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        return ListView.separated(
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
                          separatorBuilder: (context, index) {
                            return const Divider();
                          },
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 70,
                  child: Center(
                    child: Obx(
                      () {
                        if (controller.processingInvite.value) {
                          return const CircularProgressIndicator();
                        }

                        if (controller.inviteError.value.isNotEmpty) {
                          return Text(
                            controller.inviteError.value,
                            style: TextStyle(
                              color: Get.theme.colorScheme.error,
                              fontSize: 16,
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                const Divider(height: 30),
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
