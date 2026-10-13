import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/review.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// The reviews table: one review per person per book, by its owner or by
/// someone who borrowed it. books!inner lets the books RLS drop reviews of
/// books the user can't see.
class ReviewsBackend {
  static final SupabaseClient _client = Supabase.instance.client;

  static const String _select =
      '*, reviewer_profile:profiles!reviewer(*), books!inner(*, profiles(*))';

  /// Debug only, opt-in: `--dart-define=SIMULATED_REVIEWS=23` pretends every
  /// book has that many reviews, so the book page's review list can be
  /// tried without real data. Release builds always use the real reviews.
  static const int _simulatedReviews =
      kReleaseMode ? 0 : int.fromEnvironment('SIMULATED_REVIEWS');

  static const String _sampleReview =
      'An absorbing read. The argument builds patiently and the last third '
      'ties everything together; I found myself rereading whole chapters. '
      'Would happily lend this to anyone curious about the subject.';

  /// One page of fake reviews, newest first. Their length varies so some
  /// clamp to 4 lines and some don't.
  static List<Review> _simulatedReviewPage(int pageKey, int pageSize) {
    final int count = (_simulatedReviews - pageKey).clamp(0, pageSize);

    return List.generate(count, (int i) {
      final int n = pageKey + i;

      return Review.fromMap({
        'id': -n - 1,
        'created_at':
            DateTime.utc(2026, 1, _simulatedReviews - n).toIso8601String(),
        'body': List.filled(1 + n % 4, _sampleReview).join(' '),
        'books': null,
        'reviewer_profile': {
          'id': 'simulated-$n',
          'username': 'reader_${n + 1}',
          'show_email': false,
        },
      });
    });
  }

  /// Everything a user reviewed, books they own and books they borrowed,
  /// newest first.
  static Future<BackendResponse> getReviewsByUser({
    required String userId,
    required int pageKey,
    required int pageSize,
  }) async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('reviews')
          .select(_select)
          .eq('reviewer', userId)
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .range(pageKey, pageKey + pageSize - 1);

      return BackendResponse(
        success: true,
        payload: response.map(Review.fromMap).toList(),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  /// A book's reviews by readers, newest first. The owner's own review is
  /// left out: the book page shows it first, from [getReview].
  static Future<BackendResponse> getReaderReviewsForBook({
    required String bookId,
    required String ownerId,
    required int pageKey,
    required int pageSize,
  }) async {
    if (_simulatedReviews > 0) {
      return BackendResponse(
        success: true,
        payload: _simulatedReviewPage(pageKey, pageSize),
      );
    }

    try {
      final List<Map<String, dynamic>> response = await _client
          .from('reviews')
          .select(_select)
          .eq('book', bookId)
          .neq('reviewer', ownerId)
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .range(pageKey, pageKey + pageSize - 1);

      return BackendResponse(
        success: true,
        payload: response.map(Review.fromMap).toList(),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  /// How many readers (not the owner) reviewed a book.
  static Future<BackendResponse<int>> getReaderReviewCountForBook({
    required String bookId,
    required String ownerId,
  }) async {
    if (_simulatedReviews > 0) {
      return BackendResponse(success: true, payload: _simulatedReviews);
    }

    try {
      final PostgrestResponse response = await _client
          .from('reviews')
          .select('id')
          .eq('book', bookId)
          .neq('reviewer', ownerId)
          .count(CountOption.exact);

      return BackendResponse(success: true, payload: response.count);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    }
  }

  /// One person's review of a book, if they wrote one.
  static Future<Review?> getReview({
    required String reviewerId,
    required String bookId,
  }) async {
    try {
      final Map<String, dynamic>? response = await _client
          .from('reviews')
          .select(_select)
          .eq('reviewer', reviewerId)
          .eq('book', bookId)
          .maybeSingle();

      return response != null ? Review.fromMap(response) : null;
    } on PostgrestException {
      return null;
    }
  }

  /// Saves the current user's review of a book; an empty one deletes it.
  static Future<BackendResponse> saveReview({
    required String bookId,
    required String? body,
  }) async {
    try {
      final String userId = UsersBackend.currentUserId;
      final String? text = body?.trim();

      if (text == null || text.isEmpty) {
        await _client
            .from('reviews')
            .delete()
            .eq('reviewer', userId)
            .eq('book', bookId);

        return BackendResponse(success: true, payload: null);
      }

      await _client.from('reviews').upsert(
        {'reviewer': userId, 'book': bookId, 'body': text},
        onConflict: 'reviewer,book',
      );

      return BackendResponse(success: true, payload: text);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  /// Reviews written by the current user's friends of books in their circle
  /// (get_circle_reviews RPC), newest first. A friend may have reviewed a
  /// book from outside it, which Home shouldn't surface.
  static Future<BackendResponse> getFriendReviews({
    required int pageKey,
    required int pageSize,
  }) async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .rpc(
            'get_circle_reviews',
            params: {'offset_num': pageKey, 'limit_num': pageSize},
          )
          .select(_select)
          .order('created_at', ascending: false)
          .order('id', ascending: false);

      return BackendResponse(
        success: true,
        payload: response.map(Review.fromMap).toList(),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }
}
