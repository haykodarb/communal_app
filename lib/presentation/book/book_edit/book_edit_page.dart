import 'dart:io';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/presentation/book/book_edit/book_edit_controller.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';

class BookEditPage extends StatelessWidget {
  const BookEditPage({super.key});

  Widget _availableForLoansPrompt(BookEditController controller) {
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
              borderColor: [Theme.of(context).colorScheme.onBackground],
              borderWidth: 0.75,
              activeBgColors: [
                [Theme.of(context).colorScheme.primary],
                [Theme.of(context).colorScheme.error]
              ],
              activeFgColor: Theme.of(context).colorScheme.onBackground,
              inactiveBgColor: Theme.of(context).colorScheme.surface,
              inactiveFgColor: Theme.of(context).colorScheme.onBackground,
              initialLabelIndex: controller.inheritedBook.available ? 0 : 1,
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

  Widget _alreadyReadPrompt(BookEditController controller) {
    return Builder(
      builder: (context) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Already read?',
              style: TextStyle(fontSize: 14),
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
              initialLabelIndex: controller.inheritedBook.read ? 0 : 1,
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

  Widget _addReviewPrompt(BookEditController controller) {
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
                  style: TextStyle(fontSize: 14),
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
                  initialLabelIndex: controller.inheritedBook.review != null ? 0 : 1,
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

  Widget _reviewTextInput(BookEditController controller) {
    return Obx(
      () {
        return Visibility(
          visible: controller.addingReview.value,
          child: CommonTextField(
            callback: controller.onReviewTextChange,
            initialValue: controller.inheritedBook.review,
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
      init: BookEditController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Edit book',
            ),
            actions: [
              Obx(
                () => controller.loading.value
                    ? SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onBackground,
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
                                    return FutureBuilder(
                                      future: BooksBackend.getBookCover(controller.inheritedBook),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return const CommonLoadingImage();
                                        }

                                        if (snapshot.data!.isEmpty) {
                                          return Container(
                                            color: Theme.of(context).colorScheme.primary,
                                            child: Icon(
                                              Icons.groups,
                                              color: Theme.of(context).colorScheme.background,
                                              size: 150,
                                            ),
                                          );
                                        }

                                        return Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.cover,
                                        );
                                      },
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
                      callback: controller.onTitleChange,
                      initialValue: controller.inheritedBook.title,
                      label: 'Title',
                      validator: (String? value) => controller.stringValidator(value, 3),
                      maxLength: 100,
                      maxLines: 2,
                    ),
                    const Divider(),
                    CommonTextField(
                      callback: controller.onAuthorChange,
                      label: 'Author',
                      initialValue: controller.inheritedBook.author,
                      validator: (String? value) => controller.stringValidator(value, 3),
                      maxLength: 100,
                      maxLines: 2,
                    ),
                    const Divider(),
                    _availableForLoansPrompt(controller),
                    const Divider(),
                    _alreadyReadPrompt(controller),
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
