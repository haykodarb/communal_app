import 'dart:io';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/tool/tool_create/tool_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';

class ToolCreatePage extends StatelessWidget {
  const ToolCreatePage({super.key});

  Widget _availableForLoansPrompt(ToolCreateController controller) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available for loans?',
              style: TextStyle(fontSize: 14),
            ),
            const Divider(),
            ToggleSwitch(
              minWidth: 60,
              minHeight: 40,
              cornerRadius: 4,
              borderColor: [Theme.of(context).colorScheme.onSurface],
              borderWidth: 0.75,
              activeBgColors: [
                [Theme.of(context).colorScheme.primary],
                [Theme.of(context).colorScheme.error]
              ],
              activeFgColor: Theme.of(context).colorScheme.onSurface,
              inactiveBgColor: Theme.of(context).colorScheme.surfaceContainer,
              inactiveFgColor: Theme.of(context).colorScheme.onSurface,
              initialLabelIndex: 0,
              totalSwitches: 2,
              iconSize: 60,
              icons: const [Icons.done, Icons.close],
              radiusStyle: true,
              onToggle: controller.onAvailableChange,
            ),
          ],
        );
      },
    );
  }

  Widget _descriptionTextInput(ToolCreateController controller) {
    return CommonTextField(
      callback: controller.onDescriptionChange,
      label: 'Description',
      validator: (String? value) => controller.stringValidator(value, 10),
      maxLength: 100,
      maxLines: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: ToolCreateController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Add Tool',
            ),
            actions: [
              Obx(
                () => controller.loading.value
                    ? SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      )
                    : IconButton(
                        onPressed: controller.onSubmitButton,
                        icon: const Icon(Icons.done),
                      ),
              ),
              const VerticalDivider(),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 300,
                      height: 400,
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 4,
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
                                      color: Theme.of(context).colorScheme.surfaceContainer,
                                      child: const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            'No\nimage',
                                            style: TextStyle(fontSize: 18),
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
                          Container(
                            width: double.maxFinite,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Colors.black.withOpacity(0.5),
                              width: double.maxFinite,
                              height: 75,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => controller.takePicture(ImageSource.camera),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
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
                    const Divider(height: 30),
                    CommonTextField(
                      callback: controller.onNameChange,
                      label: 'Name',
                      validator: (String? value) => controller.stringValidator(value, 3),
                      maxLength: 100,
                      maxLines: 2,
                    ),
                    const Divider(),
                    _availableForLoansPrompt(controller),
                    const Divider(),
                    _descriptionTextInput(controller),
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
