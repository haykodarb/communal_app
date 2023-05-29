import 'package:get/get.dart';

class Book {
  String author;
  String title;
  String publisher;
  String? image_path;
  String? ownerName;
  String? ownerId;
  int? id;

  RxBool deleting = false.obs;

  Book({
    required this.author,
    required this.title,
    required this.publisher,
    this.id,
    this.image_path,
    this.ownerName,
    this.ownerId,
  });
}
