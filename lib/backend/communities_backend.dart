import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/book.dart';
import 'package:biblioteca/models/community.dart';
import 'package:biblioteca/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunitiesBackend {
  static Future<bool> isUserAdmin(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic> membershipResponse = await client.from('memberships').select().match(
      {
        'member': userId,
        'community': community.id,
      },
    ).maybeSingle();

    return membershipResponse.isNotEmpty && (membershipResponse['is_admin'] as bool);
  }

  static Future<BackendReponse> getBooksInCommunity(Community community, int index) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<dynamic> membershipResponse = await client.from('memberships').select().eq('community', community.id);

    final List<String> listOfUserIDs = membershipResponse.map(
      (element) {
        return element['member'] as String;
      },
    ).toList();

    final List<dynamic> booksResponse =
        await client.from('books').select().in_('owner', listOfUserIDs).order('id').range(
              index * 10,
              index * 10 + 10,
            );

    final List<Book> listOfBooks = booksResponse
        .map(
          (e) => Book(
            id: e['id'],
            title: e['title'],
            author: e['author'],
            publisher: e['publisher'],
            image_path: e['image_path'],
          ),
        )
        .toList();

    return BackendReponse(
      success: listOfBooks.isNotEmpty,
      payload: listOfBooks,
    );
  }

  static Future<BackendReponse> getCommunitiesForUser() async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final List<dynamic> response = await client.from('memberships').select().eq('member', userId).order(
          'joined_at',
          ascending: true,
        );

    if (response.isEmpty) {
      return BackendReponse(success: false, payload: null);
    }

    final List<String> listOfCommunityIds = response.map((element) => element['community'] as String).toList();

    final List<dynamic> communitiesResponse = await client.from('communities').select().in_(
          'id',
          listOfCommunityIds,
        );

    if (response.isEmpty) {
      return BackendReponse(success: false, payload: null);
    }

    final List<Community> listOfCommunities = communitiesResponse
        .map(
          (dynamic element) => Community(
            name: element['name'],
            description: element['description'],
            id: element['id'],
          ),
        )
        .toList();

    return BackendReponse(success: true, payload: listOfCommunities);
  }

  static Future<BackendReponse> createCommunity(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic> createCommunityResponse = await client
        .from('communities')
        .insert(
          {
            'name': community.name,
            'description': community.description,
            'created_by': userId,
          },
        )
        .select()
        .single();

    if (createCommunityResponse.isEmpty) {
      return BackendReponse(
        success: false,
        payload: '',
      );
    }

    final Map<String, dynamic> createMembershipResponse = await client
        .from('memberships')
        .insert(
          {
            'member': userId,
            'community': createCommunityResponse['id'],
            'is_admin': true,
            'joined_at': DateTime.now().toIso8601String(),
          },
        )
        .select()
        .single();

    return BackendReponse(
      success: createMembershipResponse.isNotEmpty,
      payload: createMembershipResponse,
    );
  }
}
