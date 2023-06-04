import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/loan.dart';
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

  static Future<BackendResponse> hasBookBeenRequestedByCurrentUser(Book book) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic>? response = await client
        .from('loans')
        .select(
          '*, communities(*), books(*, profiles(*)), profiles(*)',
        )
        .match(
      {
        'book': book.id,
        'loanee': userId,
      },
    ).maybeSingle();

    if (response != null && response.isNotEmpty) {
      final Loan loan = Loan.fromMap(response);

      return BackendResponse(success: true, payload: loan);
    }

    return BackendResponse(
      success: response != null && response.isNotEmpty,
      payload: '',
    );
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
            '*, communities(*), books(*, profiles(*)), profiles(*)',
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