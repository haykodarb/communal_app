import 'dart:io';

import 'package:biblioteca/presentation/common/text_field.dart';
import 'package:biblioteca/presentation/mybooks/addbook/addbook_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddBookPage extends StatelessWidget {
  const AddBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Book',
        ),
      ),
      body: GetBuilder(
          init: AddBookController(),
          builder: (controller) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: Container(
                          padding: EdgeInsets.zero,
                          height: 300,
                          child: Column(
                            children: [
                              Expanded(
                                child: Obx(
                                  () {
                                    if (controller.selectedFile.value != null) {
                                      return Image.file(
                                        File(controller.selectedFile.value!.path),
                                      );
                                    } else {
                                      return Card(
                                        color: Theme.of(context).colorScheme.surface,
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              'Agregar imagen',
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
                              SizedBox(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: controller.takePictureFromCamera,
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        size: 30,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: controller.takePictureFromGallery,
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
                      ),
                      CustomTextField(
                        callback: controller.onTitleChange,
                        label: 'Title',
                        validator: controller.stringValidator,
                        maxLength: 100,
                        maxLines: 2,
                      ),
                      CustomTextField(
                        callback: controller.onAuthorChange,
                        label: 'Author',
                        validator: controller.stringValidator,
                      ),
                      CustomTextField(
                        callback: controller.onPublisherChange,
                        label: 'Publisher',
                        validator: controller.stringValidator,
                      ),
                      Obx(
                        () => Visibility(
                          visible: controller.loading.value,
                          child: const SizedBox(
                            height: 100,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                      ),
                      Obx(
                        () => Visibility(
                          visible: controller.errorMessage.value != '',
                          child: SizedBox(
                            height: 100,
                            child: Text(
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
                      ElevatedButton(
                        onPressed: controller.onSubmitButton,
                        child: const Text('Add Book'),
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
