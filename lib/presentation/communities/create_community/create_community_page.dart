import 'package:biblioteca/presentation/common/text_field.dart';
import 'package:biblioteca/presentation/communities/create_community/create_community_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateCommunityPage extends StatelessWidget {
  const CreateCommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CreateCommunityController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 30),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        CustomTextField(
                          callback: controller.onNameChange,
                          label: 'Name',
                          validator: (value) => controller.stringValidator(value, 4),
                        ),
                        const Divider(),
                        CustomTextField(
                          callback: controller.onDescriptionChange,
                          label: 'Description',
                          maxLines: 6,
                          minLines: 6,
                          maxLength: 150,
                          validator: (value) => controller.stringValidator(value, 10),
                        ),
                      ],
                    ),
                    Obx(
                      () => Visibility(
                        visible: controller.loading.value,
                        child: const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                    Obx(
                      () => Visibility(
                        visible: controller.errorMessage.value != '',
                        child: SizedBox(
                          height: 100,
                          child: Text(
                            controller.errorMessage.value,
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: controller.onSubmit,
                      child: const Text('Create Community'),
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
