import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/invitation.dart';
import 'package:communal/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersBackend {
  static Future<BackendResponse> searchUsers(String query) async {
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

    return BackendResponse(success: response.isNotEmpty, payload: profiles);
  }

  static Future<BackendResponse> respondToInvitation(Invitation invitation, bool accept) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic> response = await client
        .from('memberships')
        .update({
          'accepted': accept,
        })
        .eq('id', invitation.id)
        .select<Map<String, dynamic>>()
        .single();

    return BackendResponse(success: response.isNotEmpty, payload: response);
  }

  static Future<BackendResponse> getInvitationsForUser() async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final List<Map<String, dynamic>> unconfirmedMemberships = await client
        .from('memberships')
        .select<List<Map<String, dynamic>>>('id, communities(id, name, description)')
        .eq('member', userId)
        .filter('accepted', 'is', null);

    final List<Invitation> invitationsList = unconfirmedMemberships
        .map(
          (element) => Invitation(
            id: element['id'],
            communityId: element['communities']['id'],
            communityName: element['communities']['name'],
            communityDescription: element['communities']['description'],
            userId: userId,
          ),
        )
        .toList();

    return BackendResponse(
      success: invitationsList.isNotEmpty,
      payload: invitationsList,
    );
  }

  static Future<BackendResponse> inviteUserToCommunity(Community community, Profile user) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic>? memberExistsResponse = await client.from('memberships').select().match({
      'community': community.id,
      'member': user.id,
      'accepted': true,
    }).maybeSingle();

    if (memberExistsResponse != null && memberExistsResponse.isNotEmpty) {
      return BackendResponse(
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

    return BackendResponse(success: createMembershipResponse.isNotEmpty, payload: createMembershipResponse);
  }

  static Future<BackendResponse> removeUserFromCommunity(Community community, Profile user) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic>? memberExistsResponse = await client.from('memberships').select().match({
      'community': community.id,
      'member': user.id,
      'accepted': true,
    }).maybeSingle();

    if (memberExistsResponse == null || memberExistsResponse.isEmpty) {
      return BackendResponse(
        success: false,
        payload: 'User does not exist in this community.',
      );
    }

    final Map<String, dynamic> deleteMembershipResponse = await client
        .from('memberships')
        .delete()
        .match(
          {
            'member': user.id,
            'community': community.id,
            'is_admin': false,
          },
        )
        .select()
        .single();

    return BackendResponse(success: deleteMembershipResponse.isNotEmpty, payload: deleteMembershipResponse);
  }

  static Future<BackendResponse<List<Profile>>> getUsersInCommunity(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<dynamic> membershipResponse =
        await client.from('memberships').select('id, is_admin, profiles(id, username)').match({
      'community': community.id,
      'accepted': true,
    }).neq('member', client.auth.currentUser!.id);

    final List<Profile> listOfProfiles = membershipResponse
        .map(
          (e) => Profile(
            username: e['profiles']['username'],
            id: e['profiles']['id'],
            is_admin: e['is_admin'],
          ),
        )
        .toList();

    print(listOfProfiles.map((e) => e.username));

    return BackendResponse(
      success: listOfProfiles.isNotEmpty,
      payload: listOfProfiles,
    );
  }
}
