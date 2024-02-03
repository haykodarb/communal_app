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
                    width: double.maxFinite,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            height: double.maxFinite,
                            child: Obx(
                              () {
                                if (controller.selectedFile.value != null) {
                                  return Image.file(
                                    File(controller.selectedFile.value!.path),
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Card(
                                    margin: EdgeInsets.zero,
                                    color: Theme.of(context).colorScheme.surface,
                                    child: const Center(
                                      child: Text(
                                        'No\nimage',
                                        style: TextStyle(fontSize: 18),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            height: double.maxFinite,
                            child: Container(
                              color: Theme.of(context).colorScheme.onBackground.withOpacity(0.35),
                              height: double.maxFinite,
                              width: 75,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    color: Theme.of(context).colorScheme.background,
                                    onPressed: () => controller.takePicture(ImageSource.camera),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
                                    color: Theme.of(context).colorScheme.background,
                                    onPressed: () => controller.takePicture(ImageSource.gallery),
                                    icon: const Icon(
                                      Icons.image,
                                      size: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
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
                  const Divider(height: 15),
                  SizedBox(
                    height: 70,
                    child: Obx(
                      () => CommonLoadingBody(
                        loading: controller.loading.value,
                        size: 40,
                        child: ElevatedButton(
                          onPressed: controller.onSubmit,
                          child: const Text(
                            'Create',
                          ),
                        ),
                      ),
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
