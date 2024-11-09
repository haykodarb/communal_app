import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/presentation/book/book_edit/book_edit_controller.dart';
import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_responsive_page.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toggle_switch/toggle_switch.dart';

class BookEditPage extends StatelessWidget {
  const BookEditPage({
    super.key,
    required this.bookId,
    this.bookOwnedController,
  });

  final String bookId;
  final BookOwnedController? bookOwnedController;

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
              borderColor: [Theme.of(context).colorScheme.onSurface],
              borderWidth: 0.75,
              activeBgColors: [
                [Theme.of(context).colorScheme.primary],
                [Theme.of(context).colorScheme.error]
              ],
              activeFgColor: Theme.of(context).colorScheme.onPrimary,
              inactiveBgColor: Theme.of(context).colorScheme.surfaceContainer,
              inactiveFgColor: Theme.of(context).colorScheme.onSurface,
              initialLabelIndex: controller.initialForm.loaned ? 1 : 0,
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

  Widget _addReviewPrompt(BookEditController controller) {
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
              initialLabelIndex: controller.initialForm.review != null ? 0 : 1,
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

  Widget _reviewTextInput(BookEditController controller) {
    return Obx(
      () {
        return Visibility(
          visible: controller.addingReview.value,
          child: CommonTextField(
            callback: controller.onReviewTextChange,
            initialValue: controller.initialForm.review,
            label: 'Review',
            validator: (String? value) => controller.stringValidator(value, 10),
            maxLength: 1000,
            maxLines: 6,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: BookEditController(
        bookId: bookId,
      ),
      builder: (controller) {
        return CommonResponsivePage(
          child: Scaffold(
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
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        )
                      : IconButton(
                          onPressed: () => controller.onSubmitButton(context),
                          icon: const Icon(Icons.done),
                        ),
                ),
              ],
            ),
            body: Obx(() {
              return CommonLoadingBody(
                loading: controller.firstLoad.value,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 20),
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
                                      if (controller.selectedBytes.value !=
                                          null) {
                                        return Image.memory(
                                          controller.selectedBytes.value!,
                                          fit: BoxFit.cover,
                                        );
                                      } else {
                                        return FutureBuilder(
                                          future: BooksBackend.getBookCover(
                                            controller.initialForm,
                                          ),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const CommonLoadingImage();
                                            }

                                            if (snapshot.data!.isEmpty) {
                                              return Container(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                child: Icon(
                                                  Atlas.users,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface,
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
                                Container(
                                  width: double.maxFinite,
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.5),
                                    width: double.maxFinite,
                                    height: 75,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        IconButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          onPressed: () => controller
                                              .takePicture(ImageSource.camera),
                                          icon: const Icon(
                                            Icons.camera_alt,
                                            size: 40,
                                          ),
                                        ),
                                        IconButton(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          onPressed: () => controller
                                              .takePicture(ImageSource.gallery),
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
                            initialValue: controller.initialForm.title,
                            label: 'Title',
                            validator: (String? value) =>
                                controller.stringValidator(value, 3),
                            maxLength: 100,
                            maxLines: 2,
                          ),
                          const Divider(),
                          CommonTextField(
                            callback: controller.onAuthorChange,
                            label: 'Author',
                            initialValue: controller.initialForm.author,
                            validator: (String? value) =>
                                controller.stringValidator(value, 3),
                            maxLength: 100,
                            maxLines: 2,
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
            }),
          ),
        );
      },
    );
  }
}
