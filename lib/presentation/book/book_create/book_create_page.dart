import 'dart:io';
import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/presentation/common/common_boolean_selector.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/book/book_create/book_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
            Obx(
              () => CommonBooleanSelector(callback: controller.onPublicChange, value: controller.bookForm.value.public),
            ),
          ],
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
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      clipBehavior: Clip.hardEdge,
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Stack(
                          children: [
                            Obx(
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
                                    child: Center(
                                      child: Text(
                                        'Add image',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            Container(
                              width: double.maxFinite,
                              padding: const EdgeInsets.only(bottom: 20),
                              alignment: Alignment.bottomCenter,
                              child: Obx(
                                () {
                                  final bool fileSelected = controller.selectedFile.value != null;

                                  final Color buttonBackground = fileSelected
                                      ? Theme.of(context).colorScheme.surfaceContainer
                                      : Theme.of(context).colorScheme.primary;

                                  final Color iconColor = fileSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onPrimary;

                                  final Border? buttonBorder = fileSelected
                                      ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
                                      : null;

                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      InkWell(
                                        onTap: () => controller.takePicture(ImageSource.camera),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: buttonBorder,
                                            borderRadius: BorderRadius.circular(10),
                                            color: buttonBackground,
                                          ),
                                          padding: const EdgeInsets.all(13),
                                          child: Icon(
                                            Atlas.camera,
                                            weight: 400,
                                            color: iconColor,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => controller.takePicture(ImageSource.gallery),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: buttonBorder,
                                            borderRadius: BorderRadius.circular(10),
                                            color: buttonBackground,
                                          ),
                                          padding: const EdgeInsets.all(13),
                                          child: Icon(
                                            Atlas.image_gallery,
                                            color: iconColor,
                                            size: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    CommonTextField(
                      callback: controller.onTitleChange,
                      inheritedController: controller.titleController,
                      label: 'Title',
                      validator: (String? value) => controller.stringValidator(value, 3),
                      maxLength: 100,
                      maxLines: 2,
                    ),
                    CommonTextField(
                      callback: controller.onAuthorChange,
                      inheritedController: controller.authorController,
                      label: 'Author',
                      validator: (String? value) => controller.stringValidator(value, 3),
                    ),
                    CommonTextField(
                      callback: controller.onReviewTextChange,
                      inheritedController: controller.authorController,
                      label: 'Review (Optional)',
                      minLines: 3,
                      maxLines: 10,
                      validator: (String? value) => controller.stringValidator(value, 10),
                    ),
                    const Divider(height: 20),
                    _availableForLoansPrompt(controller),
                    const Divider(height: 20),
                    ElevatedButton(onPressed: controller.onSubmitButton, child: const Text('Add')),
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
