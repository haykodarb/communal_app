import 'dart:io';
import 'package:communal/presentation/common/common_loading_body.dart';
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
              style: TextStyle(fontSize: 16),
            ),
            const Divider(),
            ToggleSwitch(
              minWidth: 60,
              minHeight: 40,
              cornerRadius: 4,
              borderColor: [Theme.of(context).colorScheme.onBackground],
              borderWidth: 0.75,
              activeBgColors: [
                [Theme.of(context).colorScheme.primary],
                [Theme.of(context).colorScheme.error]
              ],
              activeFgColor: Theme.of(context).colorScheme.onBackground,
              inactiveBgColor: Theme.of(context).colorScheme.surface,
              inactiveFgColor: Theme.of(context).colorScheme.onBackground,
              initialLabelIndex: 0,
              totalSwitches: 2,
              iconSize: 60,
              icons: const [Icons.check, Icons.close],
              radiusStyle: true,
              onToggle: controller.onAvailableChange,
            ),
          ],
        );
      },
    );
  }

  Widget _alreadyReadPrompt(BookCreateController controller) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Already read?',
              style: TextStyle(fontSize: 16),
            ),
            const Divider(),
            ToggleSwitch(
              minWidth: 60,
              minHeight: 40,
              cornerRadius: 4,
              borderColor: [Theme.of(context).colorScheme.onBackground],
              borderWidth: 0.75,
              activeBgColors: [
                [Theme.of(context).colorScheme.primary],
                [Theme.of(context).colorScheme.error]
              ],
              activeFgColor: Theme.of(context).colorScheme.onBackground,
              inactiveBgColor: Theme.of(context).colorScheme.surface,
              inactiveFgColor: Theme.of(context).colorScheme.onBackground,
              initialLabelIndex: 1,
              totalSwitches: 2,
              iconSize: 60,
              icons: const [Icons.check, Icons.close],
              radiusStyle: true,
              onToggle: controller.onReadChange,
            ),
          ],
        );
      },
    );
  }

  Widget _addReviewPrompt(BookCreateController controller) {
    return Obx(
      () => Visibility(
        visible: controller.allowReview.value,
        child: Builder(
          builder: (context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add a review?',
                  style: TextStyle(fontSize: 16),
                ),
                const Divider(),
                ToggleSwitch(
                  minWidth: 60,
                  minHeight: 40,
                  cornerRadius: 4,
                  borderColor: [Theme.of(context).colorScheme.onBackground],
                  borderWidth: 0.75,
                  activeBgColors: [
                    [Theme.of(context).colorScheme.primary],
                    [Theme.of(context).colorScheme.error]
                  ],
                  activeFgColor: Theme.of(context).colorScheme.onBackground,
                  inactiveBgColor: Theme.of(context).colorScheme.surface,
                  inactiveFgColor: Theme.of(context).colorScheme.onBackground,
                  initialLabelIndex: 1,
                  totalSwitches: 2,
                  iconSize: 60,
                  icons: const [Icons.check, Icons.close],
                  radiusStyle: true,
                  onToggle: controller.onAddReviewChange,
                ),
              ],
            );
          },
        ),
      ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Book',
        ),
      ),
      body: GetBuilder(
          init: BookCreateController(),
          builder: (controller) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.zero,
                        height: 250,
                        child: Row(
                          children: [
                            Expanded(
                              child: AspectRatio(
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
                                          color: Theme.of(context).colorScheme.surface,
                                          child: const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text(
                                                'No\nimage',
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
                              width: 100,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () => controller.takePicture(ImageSource.camera),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 30,
                                    ),
                                  ),
                                  const Divider(),
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
                      const Divider(height: 30),
                      CommonTextField(
                        callback: controller.onTitleChange,
                        label: 'Title',
                        validator: (String? value) => controller.stringValidator(value, 3),
                        maxLength: 100,
                        maxLines: 2,
                      ),
                      const Divider(),
                      CommonTextField(
                        callback: controller.onAuthorChange,
                        label: 'Author',
                        validator: (String? value) => controller.stringValidator(value, 3),
                      ),
                      const Divider(),
                      _availableForLoansPrompt(controller),
                      const Divider(),
                      _alreadyReadPrompt(controller),
                      const Divider(),
                      _addReviewPrompt(controller),
                      const Divider(),
                      _reviewTextInput(controller),
                      const Divider(height: 30),
                      Obx(
                        () {
                          return CommonLoadingBody(
                            loading: controller.loading.value,
                            child: ElevatedButton(
                              onPressed: controller.onSubmitButton,
                              child: const Text('Add'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
