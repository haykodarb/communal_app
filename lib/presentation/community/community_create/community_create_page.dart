import 'dart:io';

import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/community/community_create/community_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CommunityCreatePage extends StatelessWidget {
  const CommunityCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommunityCreateController(),
      builder: (controller) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    height: 300,
                    child: Column(
                      children: [
                        Expanded(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Obx(
                                () {
                                  if (controller.selectedFile.value != null) {
                                    return Image.file(
                                      File(controller.selectedFile.value!.path),
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    return Card(
                                      color: Theme.of(context).colorScheme.surface,
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            'Add\nimage',
                                            style: TextStyle(fontSize: 20),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () => controller.takePicture(ImageSource.camera),
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                ),
                              ),
                              const VerticalDivider(),
                              IconButton(
                                onPressed: () => controller.takePicture(ImageSource.gallery),
                                icon: const Icon(
                                  Icons.image,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  CommonTextField(
                    callback: controller.onNameChange,
                    label: 'Name',
                    validator: (value) => controller.stringValidator(value, 4),
                  ),
                  const Divider(),
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
                              fontSize: 16,
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
