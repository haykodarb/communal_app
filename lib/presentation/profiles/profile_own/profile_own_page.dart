import 'package:communal/backend/users_backend.dart';
import 'package:communal/presentation/common/common_circular_avatar.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_info.dart';
import 'package:communal/presentation/profiles/profile_own/profile_own_controller.dart';
import 'package:communal/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicons/unicons.dart';

class ProfileOwnPage extends StatelessWidget {
  const ProfileOwnPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ProfileOwnController(),
      builder: (ProfileOwnController controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                onPressed: () => Get.toNamed(RouteNames.profileOwnEditPage, arguments: {
                  'profile': UsersBackend.currentUserProfile.value,
                }),
                icon: const Icon(UniconsLine.edit),
              ),
            ],
          ),
          drawer: CommonDrawerWidget(),
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Obx(() => CommonCircularAvatar(profile: UsersBackend.currentUserProfile.value, radius: 80)),
                        const VerticalDivider(width: 25),
                        Obx(
                          () => Text(
                            UsersBackend.currentUserProfile.value.username,
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Obx(
                      () {
                        if (UsersBackend.currentUserProfile.value.email == null) {
                          return const SizedBox.shrink();
                        }

                        return CommonTextInfo(
                          label: 'Email',
                          text: UsersBackend.currentUserProfile.value.email!,
                          size: 16,
                        );
                      },
                    ),
                    const Divider(),
                    Obx(
                      () {
                        if (UsersBackend.currentUserProfile.value.bio == null) {
                          return const SizedBox.shrink();
                        }

                        return CommonTextInfo(
                          label: 'Bio',
                          text: UsersBackend.currentUserProfile.value.bio ?? '',
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
