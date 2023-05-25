import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunitiesBackend {
  static Future<BackendReponse> createCommunity(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    print('Userid: $userId');

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

    print('createCommunityResponse: $createCommunityResponse');

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

    print('createMembershipResponse: $createMembershipResponse');

    return BackendReponse(
      success: createMembershipResponse.isNotEmpty,
      payload: createMembershipResponse,
    );
  }
}
