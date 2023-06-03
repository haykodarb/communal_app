import 'dart:io';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
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
  final Rxn<File> selectedFile = Rxn<File>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Future<void> onInit() async {
    super.onInit();
  }

  Future<void> takePicture(ImageSource source) async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 80,
      maxHeight: 640,
      maxWidth: 480,
    );

    if (pickedImage == null) return;

    selectedFile.value = File(pickedImage.path);
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

      if (selectedFile.value == null) {
        errorMessage.value = 'Please add a book cover image.';
        loading.value = false;
        return;
      }

      final BackendResponse response = await BooksBackend.addBook(
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
