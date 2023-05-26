import 'dart:io';

import 'package:biblioteca/backend/books_backend.dart';
import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/book.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BookCreateController extends GetxController {
  final Rx<Book> bookForm = Book(
    author: '',
    title: '',
    publisher: '',
  ).obs;

  final RxString errorMessage = ''.obs;
  final RxBool loading = false.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<XFile> selectedFile = Rxn<XFile>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  Future<void> takePictureFromGallery() async {
    selectedFile.value = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxHeight: 800,
      maxWidth: 600,
    );
  }

  Future<void> takePictureFromCamera() async {
    selectedFile.value = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxHeight: 800,
      maxWidth: 600,
    );
  }

  void onTitleChange(String value) {
    bookForm.update(
      (Book? val) {
        val!.title = value;
      },
    );
  }

  void onAuthorChange(String value) {
    bookForm.update(
      (Book? val) {
        val!.author = value;
      },
    );
  }

  void onPublisherChange(String value) {
    bookForm.update(
      (Book? val) {
        val!.publisher = value;
      },
    );
  }

  String? stringValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (value.length < 4) {
      return 'Must be at least 4 characters long.';
    }

    return null;
  }

  Future<void> onSubmitButton() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;
      errorMessage.value = '';

      final BackendReponse response = await BooksBackend.addBook(
        bookForm.value,
        File(selectedFile.value!.path),
      );

      loading.value = false;

      if (response.success) {
        errorMessage.value = 'Book added.';

        Get.back<Book>(
          result: response.payload,
        );
      } else {
        errorMessage.value = 'Adding book failed.';
      }
    }
  }
}
