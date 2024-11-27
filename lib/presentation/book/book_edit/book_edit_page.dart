import 'package:atlas_icons/atlas_icons.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/presentation/book/book_edit/book_edit_controller.dart';
import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_boolean_selector.dart';
import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_loading_image.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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
            Obx(
              () => CommonBooleanSelector(
                callback: controller.onPublicChange,
                value: controller.bookForm.value.public,
              ),
            ),
          ],
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
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Edit book',
            ),
          ),
          body: Obx(() {
            return CommonLoadingBody(
              loading: controller.firstLoad.value,
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
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
                                padding: const EdgeInsets.only(bottom: 20),
                                alignment: Alignment.bottomCenter,
                                child: Obx(
                                  () {
                                    final bool fileSelected =
                                        controller.selectedBytes.value != null;

                                    final Color buttonBackground = fileSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .surfaceContainer
                                        : Theme.of(context).colorScheme.primary;

                                    final Color iconColor = fileSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onPrimary;

                                    final Border? buttonBorder = fileSelected
                                        ? Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 2)
                                        : null;

                                    if (kIsWeb) {
                                      return InkWell(
                                        onTap: () => controller.takePicture(
                                          ImageSource.gallery,
                                          context,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            border: buttonBorder,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: buttonBackground,
                                          ),
                                          padding: const EdgeInsets.all(13),
                                          child: Icon(
                                            Atlas.image_gallery,
                                            color: iconColor,
                                            size: 24,
                                          ),
                                        ),
                                      );
                                    }

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          onTap: () => controller.takePicture(
                                            ImageSource.camera,
                                            context,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: buttonBorder,
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                                          onTap: () => controller.takePicture(
                                            ImageSource.gallery,
                                            context,
                                          ),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: buttonBorder,
                                              borderRadius:
                                                  BorderRadius.circular(10),
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
                        const Divider(height: 30),
                        Form(
                          child: Column(
                            children: [
                              CommonTextField(
                                callback: controller.onTitleChange,
                                initialValue: controller.initialForm.title,
                                label: 'Title',
                                submitCallback: (_) =>
                                    controller.onSubmitButton(context),
                                validator: (String? value) =>
                                    controller.stringValidator(value, 3, false),
                                maxLength: 100,
                                maxLines: 2,
                              ),
                              const Divider(height: 5),
                              CommonTextField(
                                callback: controller.onAuthorChange,
                                initialValue: controller.initialForm.author,
                                submitCallback: (_) =>
                                    controller.onSubmitButton(context),
                                label: 'Author',
                                validator: (String? value) =>
                                    controller.stringValidator(value, 3, false),
                              ),
                              const Divider(height: 5),
                              CommonTextField(
                                callback: controller.onReviewTextChange,
                                initialValue: controller.initialForm.review,
                                label: 'Review (Optional)',
                                minLines: 3,
                                maxLines: 10,
                                validator: (String? value) =>
                                    controller.stringValidator(value, 10, true),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 20),
                        _availableForLoansPrompt(controller),
                        const Divider(height: 20),
                        Obx(
                          () => CommonLoadingBody(
                            loading: controller.loading.value,
                            child: ElevatedButton(
                              onPressed: () =>
                                  controller.onSubmitButton(context),
                              child: const Text('Save'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
