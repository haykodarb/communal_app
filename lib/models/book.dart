import 'dart:convert';

import 'package:get/get.dart';

class Book {
  String author;
  String title;
  String publisher;
  String? image_path;
  int? id;

  RxBool deleting = false.obs;

  Book({
    required this.author,
    required this.title,
    required this.publisher,
    this.id,
    this.image_path,
  });

  static List<Book> getListOfBooks(List<dynamic> payload) {
    return payload
        .map(
          (element) => Book(
            author: element['author'],
            publisher: element['publisher'],
            title: element['title'],
          ),
        )
        .toList();
  }

  @override
  String toString() {
    return jsonEncode({
      'author': author,
      'title': title,
      'publisher': publisher,
    });
  }
}
