import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_create/community_discussions_topic_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        return Scaffold(
          appBar: AppBar(
            title: Text('Create topic'.tr),
          ),
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Form(
              key: controller.formKey,
              child: Column(
                children: [
                  CommonTextField(
                    callback: controller.onNameChange,
                    submitCallback: (_) => controller.onSubmit(context),
                    label: 'Name'.tr,
                    validator: (value) => controller.stringValidator(value, 4),
                  ),
                  const Divider(height: 10),
                  Obx(
                    () {
                      return CommonLoadingBody(
                        loading: controller.loading.value,
                        child: ElevatedButton(
                          onPressed: () => controller.onSubmit(context),
                          child: Text(
                            'Create'.tr,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
