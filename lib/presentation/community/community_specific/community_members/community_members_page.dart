import 'package:biblioteca/models/profile.dart';
import 'package:biblioteca/presentation/community/community_specific/community_members/community_members_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityMembersPage extends StatelessWidget {
  const CommunityMembersPage({super.key});

  Widget _userElement(CommunityMembersController controller, Profile user) {
    return Card(
      child: SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(user.username),
              Text((user.is_admin != null && user.is_admin!) ? 'Admin' : ''),
              Visibility(
                visible: controller.community.isCurrentUserAdmin != null && controller.community.isCurrentUserAdmin!,
                child: PopupMenuButton(
                  itemBuilder: (context) {
                    return <PopupMenuEntry>[];
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityMembersController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Members'),
          ),
          body: Obx(
            () {
              if (controller.loading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadUsers,
                child: Obx(
                  () => ListView.separated(
                    padding: const EdgeInsets.all(30),
                    itemCount: controller.listOfMembers.length,
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                    itemBuilder: (context, index) {
                      return _userElement(
                        controller,
                        controller.listOfMembers[index],
                      );
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
