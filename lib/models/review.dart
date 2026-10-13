import 'package:communal/models/book.dart';
import 'package:communal/models/profile.dart';

/// A person's review of a book, whether they own it or borrowed it.
class Review {
  int id;
  DateTime created_at;
  String body;
  Profile reviewer;
  Book book;

  Review({
    required this.id,
    required this.created_at,
    required this.body,
    required this.reviewer,
    required this.book,
  });

  Review.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']).toLocal(),
        body = map['body'],
        reviewer = Profile.fromMap(map['reviewer_profile']),
        book = map['books'] != null ? Book.fromMap(map['books']) : Book.empty();

  /// The owner's own review of their book, rather than a borrower's.
  bool get isByOwner => reviewer.id == book.owner.id;
}
