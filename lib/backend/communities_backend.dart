import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunitiesBackend {
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
