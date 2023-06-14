import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/loan.dart';
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

    final Map<String, dynamic>? response =
        await client.from('loans').delete().eq('id', loan.id).select<Map<String, dynamic>?>().maybeSingle();

    if (response == null || response.isEmpty) {
      return BackendResponse(success: false, payload: 'No requests have been made for your books yet.');
    }

    return BackendResponse(success: true, payload: 'Loan deleted successfully.');
  }

  static Future<BackendResponse> setLoanParameterTrue(Loan loan, String parameter) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic>? response = await client
        .from('loans')
        .update({parameter: true})
        .eq('id', loan.id)
        .select<Map<String, dynamic>?>()
        .maybeSingle();

    if (response == null || response.isEmpty) {
      return BackendResponse(success: false, payload: '');
    }

    return BackendResponse(success: true, payload: '');
  }

  static Future<BackendResponse> getLoanCountWhere(LoansRequestType requestType) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    Map<String, dynamic> query;

    switch (requestType) {
      case LoansRequestType.userIsOwner:
        query = {
          'books.owner': userId,
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

    final PostgrestResponse response = await client
        .from('loans')
        .select(
          '*,  books!inner(*, profiles(*))',
          const FetchOptions(
            count: CountOption.exact,
            // head: true,
          ),
        )
        .match(query);

    return BackendResponse(success: true, payload: response.count);
  }

  /// If book is already loaned to another user, returns false and that loan.
  /// If book is not loaned and current user has already requested it, returns true and that loan.
  /// Else returns false and no payload.
  static Future<BackendResponse> getCurrentLoanForBook(Book book) async {
    final SupabaseClient client = Supabase.instance.client;
    final String userId = client.auth.currentUser!.id;

    final List<dynamic> response = await client
        .from('loans')
        .select(
          '*, communities(*), books!inner(*, profiles(*)), profiles(*)',
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
      print('Book is already loaned');
      return BackendResponse(
        success: true,
        payload: loanMadeByAnotherUser,
      );
    }

    final Loan? requestByCurrentUser = loans.firstWhereOrNull(
      (element) => element.loanee.id == userId && !element.rejected,
    );

    if (requestByCurrentUser != null) {
      print('Current user already requested this book.');
    } else {
      print('Book is available and user hasn\'t requested it yet');
    }

    return BackendResponse(
      success: requestByCurrentUser != null,
      payload: requestByCurrentUser,
    );
  }

  static Future<BackendResponse> getLoansWhere(LoansRequestType requestType) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    Map<String, dynamic> query;

    switch (requestType) {
      case LoansRequestType.userIsOwner:
        query = {
          'books.owner': userId,
          'returned': false,
          'rejected': false,
        };
        break;

      case LoansRequestType.userIsLoanee:
        query = {
          'loanee': userId,
          'returned': false,
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

    final List<dynamic> response = await client
        .from('loans')
        .select(
          '*, communities(*), books!inner(*, profiles(*)), profiles(*)',
        )
        .match(query);

    if (response.isEmpty) {
      return BackendResponse(success: false, payload: 'No requests have been made for your books yet.');
    }

    final List<Loan> loanList = response.map((element) => Loan.fromMap(element)).toList();

    return BackendResponse(success: true, payload: loanList);
  }

  static Future<BackendResponse> requestBookLoanInCommunity(Book book, Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic>? loanAlreadyRequested = await client.from('loans').select().match(
      {
        'book': book.id,
        'loanee': userId,
      },
    ).maybeSingle();

    if (loanAlreadyRequested == null || loanAlreadyRequested.isEmpty) {
      final Map<String, dynamic>? response = await client
          .from('loans')
          .insert(
            {
              'loanee': userId,
              'book': book.id,
              'community': community.id,
            },
          )
          .select<Map<String, dynamic>?>(
            '*, communities(*), books!inner(*, profiles(*)), profiles(*)',
          )
          .maybeSingle();

      if (response == null) {
        return BackendResponse(success: false, payload: 'Could not request book, please try again.');
      }

      return BackendResponse(
        success: true,
        payload: Loan.fromMap(response),
      );
    } else {
      return BackendResponse(
        success: false,
        payload: 'You have already requested a loan on this book. Please wait for the owner to respond.',
      );
    }
  }
}
