import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_responsive_page.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_create/community_discussions_topic_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

class CommunityDiscussionsTopicCreatePage extends StatelessWidget {
  const CommunityDiscussionsTopicCreatePage({
    super.key,
    required this.communityId,
  });

  final String communityId;

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityDiscussionsTopicCreateController(communityId: communityId),
      builder: (controller) {
        return CommonResponsivePage(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Create topic'),
           ),
            resizeToAvoidBottomInset: false,
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    CommonTextField(
                      callback: controller.onNameChange,
                      label: 'Name',
                      validator: (value) =>
                          controller.stringValidator(value, 4),
                    ),
                    const Divider(height: 15),
                    SizedBox(
                      height: 70,
                      child: Obx(
                        () => CommonLoadingBody(
                          loading: controller.loading.value,
                          size: 40,
                          child: Obx(
                            () => Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 15),
                    ElevatedButton(
                      onPressed:() => controller.onSubmit(context),
                      child: const Text(
                        'Create',
                      ),
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
