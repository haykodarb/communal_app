import 'dart:typed_data';

import 'package:communal/models/profile.dart';
import 'package:get/get.dart';

class Book {
  String id;
  DateTime created_at;
  String author;
  String title;
  String image_path;
  String? review;
  Profile owner;
  bool loaned;
  bool public;

  Uint8List? image_data;

  RxBool loading = false.obs;

  Book({
    required this.id,
    required this.created_at,
    required this.author,
    required this.title,
    required this.owner,
    required this.image_path,
    required this.loaned,
    required this.review,
    required this.public,
  });

  Book.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']),
        title = map['title'],
        author = map['author'],
        owner = Profile.fromMap(map['profiles']),
        loaned = map['loaned'],
        review = map['review'],
        public = map['public'],
        image_path = map['image_path'];

  Book.empty()
      : id = '',
        created_at = DateTime.now(),
        title = '',
        author = '',
        image_path = '',
        loaned = true,
        public = true,
        owner = Profile.empty();
}
