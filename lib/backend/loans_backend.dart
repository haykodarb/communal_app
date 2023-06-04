import 'package:communal/models/backend_response.dart';
import 'package:communal/models/book.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/loan.dart';
import 'package:communal/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoansBackend {
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
      final Loan loan = Loan(
        id: response['id'],
        created_at: DateTime.parse(response['created_at']).toLocal(),
        community: Community(
          id: response['communities']['id'],
          name: response['communities']['name'],
          owner: response['communities']['owner'],
          image_path: response['communities']['image_path'],
        ),
        book: book,
        loanee: Profile.fromMap(response['profiles']),
        accepted: response['accepted'],
        returned: response['returned'],
      );

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
        payload: Loan(
          id: response['id'],
          created_at: DateTime.parse(response['created_at']).toLocal(),
          community: Community(
            id: response['communities']['id'],
            name: response['communities']['name'],
            owner: response['communities']['owner'],
            image_path: response['communities']['image_path'],
          ),
          book: book,
          loanee: Profile.fromMap(response['profiles']),
          accepted: response['accepted'],
          returned: response['returned'],
        ),
      );
    } else {
      return BackendResponse(
        success: false,
        payload: 'You have already requested a loan on this book. Please wait for the owner to respond.',
      );
    }
  }
}
