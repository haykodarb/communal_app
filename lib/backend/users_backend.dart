import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/invitation.dart';
import 'package:communal/models/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersBackend {
  static String getCurrentUsername() {
    final GoTrueClient client = Supabase.instance.client.auth;

    if (client.currentUser == null &&
        client.currentUser!.userMetadata == null &&
        client.currentUser!.userMetadata!['username'] == null) return 'No user';

    return client.currentUser!.userMetadata!['username'];
  }

  static Future<BackendResponse> searchUsers(String query) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final List<Map<String, dynamic>> response = await client
        .from('profiles')
        .select<List<Map<String, dynamic>>>()
        .neq('id', userId)
        .like('username', '%$query%')
        .limit(10);

    final List<Profile> profiles = response
        .map(
          (element) => Profile.fromMap(element),
        )
        .toList();

    return BackendResponse(
      success: response.isNotEmpty,
      payload: profiles,
    );
  }

  static Future<BackendResponse> respondToInvitation(Invitation invitation, bool accept) async {
    final SupabaseClient client = Supabase.instance.client;

    if (accept) {
      final Map<String, dynamic> response = await client
          .from('memberships')
          .update({
            'accepted': true,
            'joined_at': 'now()',
          })
          .eq('id', invitation.id)
          .select<Map<String, dynamic>>()
          .single();

      return BackendResponse(success: response.isNotEmpty, payload: response);
    } else {
      final Map<String, dynamic> response =
          await client.from('memberships').delete().eq('id', invitation.id).select<Map<String, dynamic>>().single();

      return BackendResponse(success: response.isNotEmpty, payload: response);
    }
  }

  static Future<BackendResponse> getInvitationsCountForUser() async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final PostgrestResponse response = await client
        .from('memberships')
        .select(
          '*',
          const FetchOptions(
            head: true,
            count: CountOption.exact,
          ),
        )
        .match(
      {
        'member': userId,
        'accepted': false,
      },
    );

    return BackendResponse(
      success: response.status == 200,
      payload: response.count,
    );
  }

  static Future<BackendResponse> getInvitationsForUser() async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final List<Map<String, dynamic>> unconfirmedMemberships =
        await client.from('memberships').select<List<Map<String, dynamic>>>('*, communities(*)').match(
      {
        'member': userId,
        'accepted': false,
      },
    );

    final List<Invitation> invitationsList = unconfirmedMemberships
        .map(
          (element) => Invitation(
            id: element['id'],
            community: Community(
              id: element['communities']['id'],
              name: element['communities']['name'],
              image_path: element['communities']['image_path'],
              owner: element['communities']['owner'],
            ),
            userId: userId,
          ),
        )
        .toList();

    return BackendResponse(
      success: invitationsList.isNotEmpty,
      payload: invitationsList,
    );
  }

  static Future<BackendResponse> makeUserAdminOfCommunity(Community community, Profile user, bool shouldBeAdmin) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic>? updateMembershipResponse = await client
        .from('memberships')
        .update(
          {
            'is_admin': shouldBeAdmin,
          },
        )
        .match(
          {
            'member': user.id,
            'community': community.id,
            'accepted': true,
          },
        )
        .select()
        .maybeSingle();

    if (updateMembershipResponse == null) {
      BackendResponse(success: false, payload: 'Failed to make user admin.');
    }

    return BackendResponse(success: updateMembershipResponse!.isNotEmpty, payload: updateMembershipResponse);
  }

  static Future<BackendResponse> inviteUserToCommunity(Community community, Profile user) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic>? memberExistsResponse = await client.from('memberships').select().match({
      'community': community.id,
      'member': user.id,
    }).maybeSingle();

    if (memberExistsResponse != null) {
      if (memberExistsResponse['accepted']) {
        return BackendResponse(
          success: false,
          payload: 'User is already a member in this community.',
        );
      } else {
        return BackendResponse(
          success: false,
          payload: 'User already has a pending invitation from this community.',
        );
      }
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

  static Future<BackendResponse> removeCurrentUserFromCommunity(Community community) async {
    final SupabaseClient client = Supabase.instance.client;
    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic>? memberExistsResponse = await client.from('memberships').select().match({
      'community': community.id,
      'member': userId,
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
            'member': userId,
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

    return BackendResponse(
      success: listOfProfiles.isNotEmpty,
      payload: listOfProfiles,
    );
  }
}
