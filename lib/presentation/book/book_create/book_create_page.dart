import 'dart:io';

import 'package:communal/presentation/common/common_loading_body.dart';
import 'package:communal/presentation/common/common_text_field.dart';
import 'package:communal/presentation/book/book_create/book_create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BookCreatePage extends StatelessWidget {
  const BookCreatePage({super.key});

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
                        height: 300,
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
                      const Divider(),
                      CommonTextField(
                        callback: controller.onTitleChange,
                        label: 'Title',
                        validator: controller.stringValidator,
                        maxLength: 100,
                        maxLines: 2,
                      ),
                      const Divider(),
                      CommonTextField(
                        callback: controller.onAuthorChange,
                        label: 'Author',
                        validator: controller.stringValidator,
                      ),
                      const Divider(),
                      SizedBox(
                        height: 70,
                        child: Obx(
                          () => CommonLoadingBody(
                            isLoading: controller.loading.value,
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
                      ElevatedButton(
                        onPressed: controller.onSubmitButton,
                        child: const Text('Add'),
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
