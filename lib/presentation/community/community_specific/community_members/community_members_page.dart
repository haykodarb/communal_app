import 'package:communal/models/profile.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';

class CommunityMembersController extends GetxController {
  final Community community = Get.arguments['community'];

  final RxList<Profile> listOfMembers = <Profile>[].obs;

  final RxBool loading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  Future<void> removeUser(Profile user) async {
    user.loading.value = true;

    final BackendResponse response = await UsersBackend.removeUserFromCommunity(community, user);

    if (response.success) {
      listOfMembers.remove(user);
      user.loading.value = false;
    }
  }

  Future<void> changeUserAdmin(Profile user, bool shouldBeAdmin) async {
    user.loading.value = true;

    final BackendResponse response = await UsersBackend.makeUserAdminOfCommunity(community, user, shouldBeAdmin);

    if (response.success) {
      user.is_admin = shouldBeAdmin;
      user.loading.value = false;
    }
  }

  Future<void> loadUsers() async {
    loading.value = true;

    final BackendResponse<List<Profile>> response = await UsersBackend.getUsersInCommunity(community);

    if (response.success) {
      listOfMembers.value = response.payload;
    }

    loading.value = false;
  }
}

class CommunityMembersPage extends StatelessWidget {
  const CommunityMembersPage({super.key});

  Widget _userElement(CommunityMembersController controller, Profile user) {
    return Card(
      child: SizedBox(
        height: 70,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Obx(
            () => CommonLoadingBody(
              isLoading: user.loading.value,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(user.username),
                  Visibility(
                    visible: user.is_admin,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        border: Border.all(
                          color: Get.theme.colorScheme.primary,
                        ),
                      ),
                      child: const Text('admin'),
                    ),
                  ),
                  Visibility(
                    visible: controller.community.isCurrentUserAdmin,
                    child: PopupMenuButton(
                      itemBuilder: (context) {
                        return <PopupMenuEntry>[
                          PopupMenuItem(
                            onTap: () => controller.changeUserAdmin(user, !user.is_admin),
                            child: Text(user.is_admin ? 'Remove as admin' : 'Make admin'),
                          ),
                          PopupMenuItem(
                            onTap: () => controller.removeUser(user),
                            child: const Text('Remove'),
                          ),
                        ];
                      },
                    ),
                  ),
                ],
              ),
            ),
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
              return CommonLoadingBody(
                isLoading: controller.loading.value,
                child: RefreshIndicator(
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
                ),
              );
            },
          ),
        );
      },
    );
  }
}
