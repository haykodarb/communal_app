import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/presentation/profiles/profile_other/profile_other_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileOtherPage extends StatelessWidget {
  const ProfileOtherPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ProfileOtherController(),
      builder: (ProfileOtherController controller) {
        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => Get.toNamed(RouteNames.messagesSpecificPage, arguments: {
                  'user': controller.profile.value,
                }),
                icon: const Icon(Atlas.comment_dots),
              ),
            ],
          ),
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => CommonCircularAvatar(profile: controller.profile.value, radius: 80)),
                        const VerticalDivider(width: 25),
                        Obx(
                          () => Text(
                            controller.profile.value.username,
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Obx(
                      () {
                        if (controller.profile.value.email == null) {
                          return const SizedBox.shrink();
                        }

                        return CommonTextInfo(
                          label: 'Email',
                          text: controller.profile.value.email!,
                          size: 16,
                        );
                      },
                    ),
                    const Divider(),
                    Obx(
                      () {
                        if (controller.profile.value.bio == null) {
                          return const SizedBox.shrink();
                        }

                        return CommonTextInfo(
                          label: 'Bio',
                          text: controller.profile.value.bio ?? '',
                          size: 16,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
