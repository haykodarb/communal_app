import 'package:communal/backend/friendships_backend.dart';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/friendship.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/presentation/profiles/common/profile_common_controller.dart';
import 'package:get/get.dart';
import 'package:communal/backend/books_backend.dart';
import 'package:communal/backend/loans_backend.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';

class ProfileOtherController extends ProfileCommonController {
  ProfileOtherController({
    required this.userId,
  });

  final String userId;

  final Rx<Profile> profile = Profile.empty().obs;
  final Rxn<Friendship> existingFriendship = Rxn<Friendship>();

  final RxBool loadingProfile = true.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    loadingProfile.value = true;

    final BackendResponse response = await UsersBackend.getUserProfile(userId);

    if (response.success) {
      profile.value = response.payload;
    }

    final BackendResponse<Friendship?> friendRes =
        await FriendshipsBackend.getFriendshipWithUser(
      userId,
    );

    print(friendRes.payload.toString());

    if (friendRes.success) {
      profile.value.friendship = friendRes.payload;
    } else {
      print(friendRes.payload);
    }

    loadingProfile.value = false;
  }

  @override
  Future<List<Book>> loadBooks(int pageKey) async {
    final BackendResponse response = await BooksBackend.getAllBooksForUser(
      pageSize: ProfileCommonController.pageSize,
      pageKey: pageKey,
      userToQuery: userId,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }

  @override
  Future<List<Loan>> loadReviews(int pageKey) async {
    final BackendResponse response = await LoansBackend.getBooksReviewedByUser(
      userId: userId,
      pageSize: ProfileCommonController.pageSize,
      pageKey: pageKey,
    );

    if (response.success) {
      return response.payload;
    }

    return [];
  }
}
