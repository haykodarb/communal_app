import 'dart:typed_data';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/presentation/book/book_owned/book_owned_controller.dart';
import 'package:communal/presentation/common/common_alert_dialog.dart';
import 'package:communal/presentation/common/common_image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class BookEditController extends GetxController {
  BookEditController({required this.bookId});

  final String bookId;
  final BookOwnedController bookOwnedController =
      Get.find<BookOwnedController>();

  final Rx<Book> bookForm = Book.empty().obs;
  Book initialForm = Book.empty();

  final RxBool allowReview = false.obs;
  final RxBool addingReview = false.obs;

  final RxBool loading = false.obs;
  final RxBool firstLoad = false.obs;

  final ImagePicker imagePicker = ImagePicker();
  final Rxn<Uint8List> selectedBytes = Rxn<Uint8List>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Future<void> onInit() async {
    super.onInit();
    if (bookOwnedController.inheritedBook != null) {
      bookForm.value = bookOwnedController.inheritedBook!;
    } else {
      firstLoad.value = true;
      final BackendResponse response = await BooksBackend.getBookById(bookId);
      firstLoad.value = false;
      if (response.success) {
        bookForm.value = response.payload;
      } else {
        Get.back();
      }
    }

    addingReview.value = bookForm.value.review != null;
    initialForm = bookForm.value;
    bookForm.refresh();
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

    final Uint8List? croppedBytes = await Get.dialog<Uint8List?>(
      CommonImageCropper(
        image: Image.memory(await pickedImage.readAsBytes()),
        aspectRatio: 3 / 4,
      ),
    );

    if (croppedBytes == null || croppedBytes.isEmpty) return;

    selectedBytes.value = croppedBytes;
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

  void onPublicChange(int? index) {
    bookForm.update(
      (Book? val) {
        val!.public = index == 0;
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

  Future<void> onSubmitButton(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      loading.value = true;

      final BackendResponse response =
          await BooksBackend.updateBook(bookForm.value, selectedBytes.value);

      loading.value = false;

      if (response.success) {
        bookOwnedController?.book.value = bookForm.value;
        if (context.mounted) {
          context.pop();
        }
      } else {
        Get.dialog(CommonAlertDialog(title: response.payload));
      }
    }
  }
}
