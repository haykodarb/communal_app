import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:communal/models/tool.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum LoansRequestType {
  userIsOwner,
  userIsLoanee,
  loanIsCompleted,
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

  static Future<BackendResponse> getLoanCountWhere(LoansRequestType requestType) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    Map<String, Object> query;

    switch (requestType) {
      case LoansRequestType.userIsOwner:
        query = {
          'owner': userId,
          'returned': false,
          'accepted': false,
          'rejected': false,
        };
        break;

      case LoansRequestType.userIsLoanee:
        query = {
          'loanee': userId,
          'returned': false,
          'rejected': false,
        };
        break;
      case LoansRequestType.loanIsCompleted:
        query = {
          'returned': true,
        };
        break;
      default:
        query = {};
        break;
    }

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

  /// If book is already loaned to another user, returns false and that loan.
  /// If book is not loaned and current user has already requested it, returns true and that loan.
  /// Else returns false and no payload.
  static Future<BackendResponse> getCurrentLoanForTool(Tool tool) async {
    final SupabaseClient client = Supabase.instance.client;
    final String userId = client.auth.currentUser!.id;

    final List<dynamic> response = await client
        .from('loans')
        .select(
          '*, communities(*), tools!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
        )
        .match(
      {
        'tool': tool.id,
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

  static Future<BackendResponse> getLoansWhere(LoansRequestType requestType) async {
    try {
      final SupabaseClient client = Supabase.instance.client;
      final String userId = UsersBackend.currentUserId;

      PostgrestFilterBuilder filter = client.from('loans').select(
            '*, communities(*), books!left(*, profiles(*)), tools!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
          );

      switch (requestType) {
        case LoansRequestType.userIsOwner:
          filter = filter.eq('returned', false).eq('rejected', false).eq('owner', userId);
          break;

        case LoansRequestType.userIsLoanee:
          filter = filter.match(
            {
              'loanee': userId,
              'returned': false,
            },
          );
          break;
        case LoansRequestType.loanIsCompleted:
          filter = filter.eq('returned', true);
          break;
        default:
          break;
      }

      final List<dynamic> response = await filter;

      if (response.isEmpty) {
        return BackendResponse(success: false, payload: 'No requests have been made for your items yet.');
      }

      final List<Loan> loanList = response.map((element) => Loan.fromMap(element)).toList();

      return BackendResponse(success: true, payload: loanList);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getCompletedLoansForItem({
    Book? book,
    Tool? tool,
  }) async {
    if (book == null && tool == null) {
      return BackendResponse(success: false, payload: "Must include a book or tool");
    }

    try {
      final SupabaseClient client = Supabase.instance.client;

      final String parameter = book == null ? 'tool' : 'book';
      final String value = book == null ? tool!.id : book.id;

      final List<Map<String, dynamic>> response = await client
          .from('loans')
          .select(
            '*, communities(*), ${parameter}s!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)',
          )
          .eq(parameter, value)
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
          .eq('returned', true)
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
    Book? book,
    Tool? tool,
  }) async {
    if (book == null && tool == null) return BackendResponse(success: false, payload: "Must include tool or book");

    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    try {
      final String parameter = book == null ? 'tool' : 'book';
      final String value = book == null ? tool!.id : book.id;

      final Map<String, dynamic> response = await client
          .from('loans')
          .insert(
            {
              'loanee': userId,
              parameter: value,
              'community': community.id,
            },
          )
          .select(
              '*, communities(*), ${parameter}s!left(*, profiles(*)), loanee_profile:profiles!loanee(*), owner_profile:profiles!owner(*)')
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
