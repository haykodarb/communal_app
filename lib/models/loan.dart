import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';

class Loan {
  String id;
  DateTime created_at;
  DateTime? accepted_at;
  DateTime? returned_at;
  Community community;
  Book book;
  Profile loanee;
  bool accepted;
  bool rejected;
  bool returned;

  Loan({
    required this.id,
    required this.created_at,
    required this.accepted_at,
    required this.returned_at,
    required this.community,
    required this.book,
    required this.loanee,
    required this.accepted,
    required this.rejected,
    required this.returned,
  });

  Loan.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']).toLocal(),
        accepted_at = DateTime.tryParse(map['accepted_at'] ?? '')?.toLocal(),
        returned_at = DateTime.tryParse(map['returned_at'] ?? '')?.toLocal(),
        community = Community(
          id: map['communities']['id'],
          name: map['communities']['name'],
          owner: map['communities']['owner'],
          image_path: map['communities']['image_path'],
        ),
        book = Book.fromMap(map['books']),
        loanee = Profile.fromMap(map['profiles']),
        accepted = map['accepted'],
        rejected = map['rejected'],
        returned = map['returned'];
}
