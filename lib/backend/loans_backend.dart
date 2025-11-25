import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/loan.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoansFilterParams {
  bool allStatus = true;
  bool accepted = false;
  bool returned = false;
  bool rejected = false;
  bool orderByDate = true;
  bool userIsOwner = true;
  bool userIsLoanee = true;

  String searchQuery = '';
}

class LoansBackend {
  static Future<BackendResponse> deleteLoan(Loan loan) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic>? response = await client
        .from('loans')
        .delete()
        .eq('id', loan.id)
        .select()
        .maybeSingle();

    if (response == null || response.isEmpty) {
      return BackendResponse(
          success: false,
          payload: 'No requests have been made for your books yet.');
    }

    return BackendResponse(
        success: true, payload: 'Loan deleted successfully.');
  }

  static Future<BackendResponse> updateLoanReview(
      Loan loan, String? review) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final Map<String, dynamic>? response = await client
          .from('loans')
          .update({'review': review})
          .eq('id', loan.id)
          .select()
          .maybeSingle();

      if (response == null || response.isEmpty) {
        return BackendResponse(
            success: false, payload: 'Could not update review.');
      }

      return BackendResponse(success: true, payload: review);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> setLoanParameterTrue(
      Loan loan, String parameter) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final Map<String, dynamic>? response = await client
          .from('loans')
          .update(
            {
              parameter: true,
            },
          )
          .eq('id', loan.id)
          .select()
          .maybeSingle();

      if (response == null || response.isEmpty) {
        return BackendResponse(success: false, payload: '');
      }

      return BackendResponse(success: true, payload: '');
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getLoanCountWhere() async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    Map<String, Object> query;

    query = {
      'owner': userId,
      'returned': false,
      'accepted': false,
      'rejected': false,
    };

    final PostgrestResponse<PostgrestList> response = await client
        .from('loans')
        .select('*')
        .match(query)
        .count(CountOption.exact);

    return BackendResponse(success: true, payload: response.count);
  }

  static Future<BackendResponse> getLoanById(String id) async {
    final SupabaseClient client = Supabase.instance.client;

    try {
      final Map<String, dynamic> response = await client
          .from('loans')
          .select(
            '*, books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
          )
          .eq('id', id)
          .single();

      return BackendResponse(
        success: response.isNotEmpty,
        payload: response.isNotEmpty ? Loan.fromMap(response) : null,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getCurrentLoanForOwnedBook(Book book) async {
    final SupabaseClient client = Supabase.instance.client;
    final String userId = client.auth.currentUser!.id;

    final List<dynamic> response = await client
        .from('loans')
        .select(
          '*, books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
        )
        .match(
      {
        'book': book.id,
        'returned': false,
      },
    ).or('loanee.eq.$userId, accepted.eq.true');

    final List<Loan> loans =
        response.map((element) => Loan.fromMap(element)).toList();

    final Loan? loanMadeByAnotherUser = loans.firstWhereOrNull(
      (element) => element.loanee.id != userId && element.accepted,
    );

    if (loanMadeByAnotherUser != null) {
      return BackendResponse(
        success: true,
        payload: loanMadeByAnotherUser,
      );
    }

    final Loan? requestByCurrentUser = loans.firstWhereOrNull(
      (element) => element.loanee.id == userId && !element.rejected,
    );

    return BackendResponse(
      success: requestByCurrentUser != null,
      payload: requestByCurrentUser,
    );
  }

  /// If book is already loaned to another user, returns true and that loan.
  /// If book is not loaned and current user has already requested it, returns true and that loan.
  /// Else returns false and no payload.
  static Future<BackendResponse> getCurrentLoanForBook(String bookId) async {
    final SupabaseClient client = Supabase.instance.client;
    final String userId = client.auth.currentUser!.id;

    final List<dynamic> response = await client
        .from('loans')
        .select(
          '*, books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
        )
        .match(
      {
        'book': bookId,
        'returned': false,
      },
    ).or('loanee.eq.$userId, accepted.eq.true');

    final List<Loan> loans =
        response.map((element) => Loan.fromMap(element)).toList();

    final Loan? loanMadeByAnotherUser = loans.firstWhereOrNull(
      (element) => element.loanee.id != userId && element.accepted,
    );

    if (loanMadeByAnotherUser != null) {
      return BackendResponse(
        success: true,
        payload: loanMadeByAnotherUser,
      );
    }

    final Loan? requestByCurrentUser = loans.firstWhereOrNull(
      (element) => element.loanee.id == userId && !element.rejected,
    );

    return BackendResponse(
      success: requestByCurrentUser != null,
      payload: requestByCurrentUser,
    );
  }

  static Future<BackendResponse> getLoansForUser(
    LoansFilterParams params,
    int pageKey,
    int pageSize,
  ) async {
    try {
      final SupabaseClient client = Supabase.instance.client;
      final String userId = UsersBackend.currentUserId;

      PostgrestFilterBuilder filter = client.from('loans').select(
            '*, books!inner(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
          );

      filter = filter.not('books', 'is', null);

      if (!params.allStatus) {
        filter = filter
            .eq('returned', params.returned)
            .eq('accepted', params.accepted)
            .eq('rejected', params.rejected);
      }

      if (params.userIsLoanee && params.userIsOwner) {
        filter = filter.or('loanee.eq.$userId,owner.eq.$userId');
      } else {
        if (params.userIsLoanee) {
          filter = filter.eq('loanee', userId);
        }
        if (params.userIsOwner) {
          filter = filter.eq('owner', userId);
        }
      }

      if (params.searchQuery.isNotEmpty) {
        filter = filter.ilike('books.title', '%${params.searchQuery}%');
      }

      PostgrestTransformBuilder transform;

      if (params.orderByDate) {
        transform = filter.order('latest_date');
      } else {
        transform = filter.order('books(title)', ascending: true);
      }

      final List<dynamic> response = await transform.range(
        pageKey,
        pageKey + pageSize - 1,
      );

      final List<Loan> loanList =
          response.map((element) => Loan.fromMap(element)).toList();

      return BackendResponse(success: true, payload: loanList);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getCompletedLoansForItem({
    required String bookId,
  }) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final List<Map<String, dynamic>> response = await client
          .from('loans')
          .select(
            '*, books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
          )
          .eq('book', bookId)
          .eq('accepted', true)
          .not('review', 'is', null);

      final List<Loan> loanList =
          response.map((element) => Loan.fromMap(element)).toList();

      return BackendResponse(success: true, payload: loanList);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getBooksReviewedByUser({
    required int pageKey,
    required int pageSize,
    String? userId,
  }) async {
    try {
      String userToQuery = userId ?? UsersBackend.currentUserId;

      final SupabaseClient client = Supabase.instance.client;

      final List<Map<String, dynamic>> response = await client
          .from('loans')
          .select(
            '*, books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
          )
          .eq('accepted', true)
          .eq('loanee', userToQuery)
          .not('book', 'is', null)
          .not('review', 'is', null)
          .range(pageKey, pageKey + pageSize - 1);

      final List<Loan> loanList =
          response.map((element) => Loan.fromMap(element)).toList();

      return BackendResponse(success: true, payload: loanList);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> requestBookLoan({
    required String bookId,
  }) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    try {
      final Map<String, dynamic> response = await client
          .from('loans')
          .insert(
            {
              'loanee': userId,
              'book': bookId,
            },
          )
          .select(
              '*, books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)')
          .single();

      return BackendResponse(
        success: true,
        payload: Loan.fromMap(response),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(
        success: false,
        payload: error.message,
      );
    }
  }
}
