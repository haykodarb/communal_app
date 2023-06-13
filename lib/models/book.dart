import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';

class Book {
  String id;
  String author;
  String title;
  String image_path;
  Profile owner;
  bool is_loaned;

  RxBool loading = false.obs;

  Book({
    required this.id,
    required this.author,
    required this.title,
    required this.owner,
    required this.image_path,
    required this.is_loaned,
  });

  Book.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        author = map['author'],
        owner = Profile(
          username: map['profiles']['username'],
          id: map['profiles']['id'],
        ),
        is_loaned = map['is_loaned'],
        image_path = map['image_path'];

  Book.empty()
      : id = '',
        title = '',
        author = '',
        image_path = '',
        is_loaned = false,
        owner = Profile(username: '', id: '');
}
