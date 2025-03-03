import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';

class Loan {
  String id;
  DateTime created_at;
  DateTime? accepted_at;
  DateTime? returned_at;
  DateTime? rejected_at;
  DateTime? latest_date;
  Community? community;
  Book book;
  Profile loanee;
  Profile owner;
  String? review;
  bool accepted;
  bool rejected;
  bool returned;

  RxBool loading = false.obs;

  String get name {
    return book.title;
  }

  String? get description {
    return book.review;
  }

  bool get isBorrowed {
    return loanee.isCurrentUser;
  }

  bool get isOwned {
    return owner.isCurrentUser;
  }

  Loan({
    required this.id,
    required this.created_at,
    required this.community,
    required this.book,
    required this.loanee,
    required this.owner,
    required this.accepted,
    required this.rejected,
    required this.returned,
  });

  Loan.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        created_at = DateTime.parse(map['created_at']).toLocal(),
        accepted_at = DateTime.tryParse(map['accepted_at'] ?? '')?.toLocal(),
        returned_at = DateTime.tryParse(map['returned_at'] ?? '')?.toLocal(),
        rejected_at = DateTime.tryParse(map['rejected_at'] ?? '')?.toLocal(),
        latest_date = DateTime.tryParse(map['latest_date'] ?? '')?.toLocal(),
        review = map['review'],
        book = map['books'] != null ? Book.fromMap(map['books']) : Book.empty(),
        owner = Profile.fromMap(map['owner_profile']),
        loanee = Profile.fromMap(map['loanee_profile']),
        accepted = map['accepted'],
        rejected = map['rejected'],
        returned = map['returned'];

  Loan.empty()
      : id = '',
        created_at = DateTime.now(),
        community = Community.empty(),
        book = Book.empty(),
        loanee = Profile.empty(),
        owner = Profile.empty(),
        accepted = false,
        rejected = false,
        returned = false;
}
