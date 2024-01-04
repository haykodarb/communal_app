import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/community/community_specific/community_discussions/community_discussions_topic_create/community_discussions_topic_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityDiscussionsTopicCreatePage extends StatelessWidget {
  const CommunityDiscussionsTopicCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityDiscussionsTopicCreateController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Create topic'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: () {
                Get.back();
              },
            ),
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
                    validator: (value) => controller.stringValidator(value, 4),
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
                    onPressed: controller.onSubmit,
                    child: const Text(
                      'Create',
                    ),
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
