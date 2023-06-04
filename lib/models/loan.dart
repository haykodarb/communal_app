import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';

class Loan {
  String id;
  DateTime created_at;
  Community community;
  Book book;
  Profile loanee;
  bool accepted;
  bool returned;

  Loan({
    required this.id,
    required this.created_at,
    required this.community,
    required this.book,
    required this.loanee,
    required this.accepted,
    required this.returned,
  });
}
