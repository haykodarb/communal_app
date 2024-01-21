import 'dart:io';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class BookCreateController extends GetxController {
  final Rx<Book> bookForm = Book.empty().obs;

  final RxBool allowReview = false.obs;
  final RxBool addingReview = false.obs;

  final RxBool loading = false.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<File> selectedFile = Rxn<File>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Future<void> onInit() async {
    super.onInit();

    bookForm.value.available = true;
  }

  Future<void> takePicture(ImageSource source) async {
    XFile? pickedImage = await imagePicker.pickImage(
      source: source,
      imageQuality: 100,
      maxHeight: 1280,
      maxWidth: 960,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedImage == null) return;

    selectedFile.value = File(pickedImage.path);
  }

  void onAddReviewChange(int? index) {
    if (index == 0) {
      addingReview.value = true;
    } else {
      addingReview.value = false;

      bookForm.update(
        (Book? val) {
          val!.review = null;
        },
      );
    }
  }

  void onReviewTextChange(String? value) {
    bookForm.update(
      (Book? val) {
        val!.review = value;
      },
    );
  }

  void onAvailableChange(int? index) {
    bookForm.update(
      (Book? val) {
        val!.available = index == 0 ? true : false;
      },
    );
  }

  void onReadChange(int? index) {
    if (index == 1) {
      onAddReviewChange(1);
    }

    allowReview.value = index == 0;

    bookForm.update(
      (Book? val) {
        val!.read = index == 0 ? true : false;
      },
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

  String? stringValidator(String? value, int length) {
    if (value == null || value.isEmpty) {
      return 'Please enter something.';
    }

    if (value.length < length) {
      return 'Must be at least $length characters long.';
    }

    return null;
  }

  Future<void> onSubmitButton() async {
    if (formKey.currentState!.validate()) {
      loading.value = true;

      if (selectedFile.value == null) {
        Get.dialog(const CommonAlertDialog(title: 'Please add a book cover image.'));
        loading.value = false;
        return;
      }

      final BackendResponse response = await BooksBackend.addBook(
        bookForm.value,
        File(selectedFile.value!.path),
      );

      loading.value = false;

      if (response.success) {
        Get.back<Book>(
          result: response.payload,
        );
      } else {
        Get.dialog(const CommonAlertDialog(title: 'Network error, please try again.'));
      }
    }
  }
}
