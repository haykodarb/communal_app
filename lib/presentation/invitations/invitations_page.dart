import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/communities_backend.dart';
import 'package:communal/models/membership.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_drawer/common_drawer_widget.dart';
import 'package:communal/presentation/invitations/invitations_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InvitationsPage extends StatelessWidget {
  const InvitationsPage({super.key});

  Widget _invitationElement(
      InvitationsController controller, Membership invitation) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Obx(
                () => CommonLoadingBody(
                  loading: invitation.loading.value,
                  child: FutureBuilder(
                    future: CommunitiesBackend.getCommunityAvatar(
                        invitation.community),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CommonLoadingImage();
                      }

                      if (snapshot.data!.isEmpty) {
                        return Container(
                          color: Theme.of(context).colorScheme.primary,
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
              ),
            ),
            SizedBox(
              height: 70,
              child: Center(
                child: Text(
                  invitation.community.name,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Expanded(child: VerticalDivider()),
                SizedBox(
                  width: 80,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.respondToInvitation(invitation, true),
                    child: const Icon(Icons.done),
                  ),
                ),
                const VerticalDivider(width: 30),
                SizedBox(
                  width: 80,
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () =>
                        controller.respondToInvitation(invitation, false),
                    child: const Icon(Icons.close),
                  ),
                ),
                const Expanded(child: VerticalDivider()),
              ],
            ),
            const Divider(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: InvitationsController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Invitations'),
          ),
          drawer: const CommonDrawerWidget(),
          body: Obx(
            () => CommonLoadingBody(
              loading: controller.loading.value,
              child: Obx(
                () {
                  if (controller.invitationsList.isEmpty) {
                    return const CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          child: Center(
                            child: Text(
                              'You have not received\nany invitations yet.',
                              style: TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    itemCount: controller.invitationsList.length,
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    itemBuilder: (context, index) {
                      return _invitationElement(
                          controller, controller.invitationsList[index]);
                    },
                    separatorBuilder: (context, index) {
                      return const Divider();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
