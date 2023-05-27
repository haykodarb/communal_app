import 'package:biblioteca/models/backend_response.dart';
import 'package:biblioteca/models/community.dart';
import 'package:biblioteca/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersBackend {
  static Future<BackendReponse> searchUsers(String query) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<Map<String, dynamic>> response =
        await client.from('profiles').select<List<Map<String, dynamic>>>().like('username', '%$query%').limit(10);

    final List<Profile> profiles = response
        .map(
          (element) => Profile(
            username: element['username'],
            id: element['id'],
          ),
        )
        .toList();

    return BackendReponse(success: response.isNotEmpty, payload: profiles);
  }

  static Future<BackendReponse> inviteUserToCommunity(Community community, Profile user) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic> memberExistsResponse = await client.from('memberships').select().match({
      'community': community.id,
      'member': user.id,
      'accepted': true,
    }).single();

    print(memberExistsResponse);

    if (memberExistsResponse.isNotEmpty) {
      return BackendReponse(
        success: false,
        payload: 'User is already a member in this community',
      );
    }

    final Map<String, dynamic> createMembershipResponse = await client
        .from('memberships')
        .insert(
          {
            'member': user.id,
            'community': community.id,
            'is_admin': false,
          },
        )
        .select()
        .single();

    print(createMembershipResponse.toString());

    return BackendReponse(success: createMembershipResponse.isNotEmpty, payload: createMembershipResponse);
  }

  static Future<BackendReponse> getUsersInCommunity(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<dynamic> membershipResponse = await client.from('memberships').select().match({
      'community': community.id,
      'accepted': true,
    }).neq('member', client.auth.currentUser!.id);

    final List<String> listOfUserIDs = membershipResponse.map(
      (element) {
        return element['member'] as String;
      },
    ).toList();

    final List<dynamic> profilesResponse = await client.from('profiles').select().in_('id', listOfUserIDs);

    final List<Profile> listOfProfiles = profilesResponse
        .map(
          (e) => Profile(
            username: e['username'],
            id: e['id'],
          ),
        )
        .toList();

    return BackendReponse(
      success: profilesResponse.isNotEmpty,
      payload: listOfProfiles,
    );
  }
}
