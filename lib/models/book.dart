import 'package:communal/models/profile.dart';
import 'package:get/get.dart';

class Book {
  String id;
  String author;
  String title;
  String image_path;
  String? review;
  Profile owner;
  bool available;
  bool read;

  RxBool loading = false.obs;

  Book({
    required this.id,
    required this.author,
    required this.title,
    required this.owner,
    required this.image_path,
    required this.available,
    required this.read,
    required this.review,
  });

  Book.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        author = map['author'],
        owner = Profile(
          username: map['profiles']['username'],
          id: map['profiles']['id'],
        ),
        available = map['available'],
        read = map['read'],
        review = map['review'],
        image_path = map['image_path'];

  Book.empty()
      : id = '',
        title = '',
        author = '',
        image_path = '',
        available = false,
        read = false,
        owner = Profile(username: '', id: '');
}
