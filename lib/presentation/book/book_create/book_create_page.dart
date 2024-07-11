import 'dart:io';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/book/book_create/book_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';

class BookCreatePage extends StatelessWidget {
  const BookCreatePage({super.key});

  Widget _availableForLoansPrompt(BookCreateController controller) {
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
              activeFgColor: Theme.of(context).colorScheme.onPrimary,
              inactiveBgColor: Theme.of(context).colorScheme.surfaceContainer,
              inactiveFgColor: Theme.of(context).colorScheme.onSurface,
              initialLabelIndex: 0,
              totalSwitches: 2,
              iconSize: 60,
              icons: const [Icons.done, Icons.close],
              radiusStyle: true,
              onToggle: controller.onPublicChange,
            ),
          ],
        );
      },
    );
  }

  Widget _addReviewPrompt(BookCreateController controller) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Add a review?',
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
              activeFgColor: Theme.of(context).colorScheme.onPrimary,
              inactiveBgColor: Theme.of(context).colorScheme.surfaceContainer,
              inactiveFgColor: Theme.of(context).colorScheme.onSurface,
              initialLabelIndex: 1,
              totalSwitches: 2,
              iconSize: 60,
              icons: const [Icons.done, Icons.close],
              radiusStyle: true,
              onToggle: controller.onAddReviewChange,
            ),
          ],
        );
      },
    );
  }

  Widget _reviewTextInput(BookCreateController controller) {
    return Obx(
      () {
        return Visibility(
          visible: controller.addingReview.value,
          child: CommonTextField(
            callback: controller.onReviewTextChange,
            label: 'Review',
            validator: (String? value) => controller.stringValidator(value, 10),
            maxLength: 100,
            maxLines: 4,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BookCreateController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Add Book',
            ),
            actions: [
              IconButton(
                onPressed: controller.scanBook,
                icon: const Icon(Icons.camera_alt_outlined),
              ),
              const VerticalDivider(),
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      width: 300,
                      height: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 4,
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
                                    color: Theme.of(context).colorScheme.surfaceContainer,
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
                            width: double.maxFinite,
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                              width: double.maxFinite,
                              height: 75,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IconButton(
                                    color: Theme.of(context).colorScheme.surface,
                                    onPressed: () => controller.takePicture(ImageSource.camera),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 40,
                                    ),
                                  ),
                                  IconButton(
                                    color: Theme.of(context).colorScheme.surface,
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
                      callback: controller.onTitleChange,
                      inheritedController: controller.titleController,
                      label: 'Title',
                      validator: (String? value) => controller.stringValidator(value, 3),
                      maxLength: 100,
                      maxLines: 2,
                    ),
                    const Divider(),
                    CommonTextField(
                      callback: controller.onAuthorChange,
                      inheritedController: controller.authorController,
                      label: 'Author',
                      validator: (String? value) => controller.stringValidator(value, 3),
                    ),
                    const Divider(),
                    _availableForLoansPrompt(controller),
                    const Divider(),
                    _addReviewPrompt(controller),
                    const Divider(),
                    _reviewTextInput(controller),
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
