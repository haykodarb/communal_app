import 'dart:io';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/openlibrary_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

class BookCreateController extends GetxController {
  final Rx<Book> bookForm = Book.empty().obs;

  final RxBool allowReview = false.obs;
  final RxBool addingReview = false.obs;

  final RxBool loading = false.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<File> selectedFile = Rxn<File>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();

  Future<void> getOpenLibraryImage(String isbnCode) async {
    final File? cover = await OpenLibraryBackend.getCoverByISBN(isbnCode);
    if (cover != null) {
      selectedFile.value = File(cover.path);
    }
  }

  Future<void> scanBook() async {
    var result = await BarcodeScanner.scan();

    if (result.type == ResultType.Barcode && result.rawContent.isNotEmpty) {
      getOpenLibraryImage(result.rawContent);

      final BackendResponse response = await OpenLibraryBackend.getBookByISBN(result.rawContent);

      if (response.success) {
        final OpenLibraryBook book = response.payload;

        if (book.title != null) {
          bookForm.value.title = book.title!;
          titleController.text = book.title!;
        }

        if (book.author != null) {
          bookForm.value.author = book.author!;
          authorController.text = book.author!;
        }

        bookForm.refresh();
      }
    }
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

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedImage.path,
      aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: Theme.of(Get.context!).colorScheme.surfaceContainer,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Crop',
        ),
      ],
    );

    if (croppedFile == null) return;

    selectedFile.value = File(croppedFile.path);
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

  void onPublicChange() {
    bookForm.update(
      (Book? val) {
        val!.public = !val.public;
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
