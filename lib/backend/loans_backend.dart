import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoansFilterParams {
  bool allStatus = true;
  bool accepted = false;
  bool returned = false;
  bool orderByDate = true;
  bool userIsOwner = true;
  bool userIsLoanee = true;

  String searchQuery = '';

  int currentIndex = 0;
}

class LoansBackend {
  static Future<BackendResponse> deleteLoan(Loan loan) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic>? response = await client.from('loans').delete().eq('id', loan.id).select().maybeSingle();

    if (response == null || response.isEmpty) {
      return BackendResponse(success: false, payload: 'No requests have been made for your books yet.');
    }

    return BackendResponse(success: true, payload: 'Loan deleted successfully.');
  }

  static Future<BackendResponse> updateLoanReview(Loan loan, String? review) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final Map<String, dynamic>? response =
          await client.from('loans').update({'review': review}).eq('id', loan.id).select().maybeSingle();

      if (response == null || response.isEmpty) {
        return BackendResponse(success: false, payload: 'Could not update review.');
      }

      return BackendResponse(success: true, payload: review);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> setLoanParameterTrue(Loan loan, String parameter) async {
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

    final PostgrestResponse<PostgrestList> response =
        await client.from('loans').select('*').match(query).count(CountOption.exact);

    return BackendResponse(success: true, payload: response.count);
  }

  static Future<BackendResponse> getLoanById(String id) async {
    final SupabaseClient client = Supabase.instance.client;

    try {
      final Map<String, dynamic> response = await client
          .from('loans')
          .select(
            '*, communities(*), books!left(*, profiles(*)), tools!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
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
          '*, communities(*), books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
        )
        .match(
      {
        'book': book.id,
        'returned': false,
      },
    ).or('loanee.eq.$userId, accepted.eq.true');

    final List<Loan> loans = response.map((element) => Loan.fromMap(element)).toList();

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
  static Future<BackendResponse> getCurrentLoanForBook(Book book) async {
    final SupabaseClient client = Supabase.instance.client;
    final String userId = client.auth.currentUser!.id;

    final List<dynamic> response = await client
        .from('loans')
        .select(
          '*, communities(*), books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
        )
        .match(
      {
        'book': book.id,
        'returned': false,
      },
    ).or('loanee.eq.$userId, accepted.eq.true');

    final List<Loan> loans = response.map((element) => Loan.fromMap(element)).toList();

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

  static Future<BackendResponse> getLoansForUser(LoansFilterParams params) async {
    try {
      final SupabaseClient client = Supabase.instance.client;
      final String userId = UsersBackend.currentUserId;

      PostgrestFilterBuilder filter = client.from('loans').select(
            '*, communities(*), books!inner(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
          );

      filter = filter.not('books', 'is', null);

      if (!params.allStatus) {
        filter = filter.eq('returned', params.returned).eq('accepted', params.accepted);
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

      final List<dynamic> response = await transform;

      final List<Loan> loanList = response.map((element) => Loan.fromMap(element)).toList();

      return BackendResponse(success: true, payload: loanList);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getCompletedLoansForItem({
    required Book book,
  }) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final List<Map<String, dynamic>> response = await client
          .from('loans')
          .select(
            '*, communities(*), books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
          )
          .eq('book', book.id)
          .eq('accepted', true)
          .not('review', 'is', null);

      final List<Loan> loanList = response.map((element) => Loan.fromMap(element)).toList();

      return BackendResponse(success: true, payload: loanList);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getBooksReviewedByUser(Profile user) async {
    try {
      final SupabaseClient client = Supabase.instance.client;

      final List<Map<String, dynamic>> response = await client
          .from('loans')
          .select(
            '*, communities(*), books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
          )
          .eq('accepted', true)
          .eq('loanee', user.id)
          .not('book', 'is', null)
          .not('review', 'is', null);

      final List<Loan> loanList = response.map((element) => Loan.fromMap(element)).toList();

      return BackendResponse(success: true, payload: loanList);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> requestItemLoanInCommunity({
    required Community community,
    required Book book,
  }) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    try {
      final Map<String, dynamic> response = await client
          .from('loans')
          .insert(
            {
              'loanee': userId,
              'book': book.id,
              'community': community.id,
            },
          )
          .select(
              '*, communities(*), books!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)')
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
