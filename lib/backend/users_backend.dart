import 'dart:io';
import 'dart:typed_data';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/membership.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class UsersBackend {
  static final SupabaseClient _client = Supabase.instance.client;
  static Rx<Profile> currentUserProfile = Profile.empty().obs;

  static get currentUserId {
    return _client.auth.currentUser!.id;
  }

  static Future<bool> validateUsername(String username) async {
    final Map<String, dynamic>? foundUsername =
        await _client.from('profiles').select().eq('username', username).maybeSingle();

    return foundUsername == null || foundUsername.isEmpty;
  }

  static Future<void> updateCurrentUserProfile() async {
    final BackendResponse response = await getUserProfile(currentUserId);

    if (response.success) {
      currentUserProfile.value = response.payload;
      currentUserProfile.refresh();
    }
  }

  static Future<Uint8List?> getProfileAvatar(Profile profile) async {
    if (profile.avatar_path != null) {
      FileInfo? file = await DefaultCacheManager().getFileFromCache(profile.avatar_path!);

      Uint8List bytes;

      if (file != null) {
        bytes = await file.file.openRead().toBytes();
      } else {
        bytes = await _client.storage.from('profile_avatars').download(profile.avatar_path!);

        await DefaultCacheManager().putFile(profile.avatar_path!, bytes, key: profile.avatar_path!);
      }

      return bytes;
    }

    return null;
  }

  static Future<BackendResponse> updateProfile(Profile profile, File? image) async {
    try {
      final String userId = _client.auth.currentUser!.id;
      final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

      String? fileName;

      if (image != null) {
        final String imageExtension = image.path.split('.').last;

        fileName = '/$userId/$currentTime.$imageExtension';

        await _client.storage.from('profile_avatars').upload(
              fileName,
              image,
              retryAttempts: 5,
            );
      } else {
        fileName = profile.avatar_path;
      }

      final Map<String, dynamic> response = await _client
          .from('profiles')
          .update(
            {
              'username': profile.username,
              'show_email': profile.show_email,
              'bio': profile.bio,
              'avatar_path': fileName,
            },
          )
          .eq('id', profile.id)
          .select('*')
          .single();

      if (response.isNotEmpty && profile.id == currentUserId) {
        currentUserProfile.value = Profile.fromMap(response);
      }

      return BackendResponse(
        success: response.isNotEmpty,
        payload: response.isNotEmpty ? Profile.fromMap(response) : 'Could not update profile. Please try again.',
      );
    } on StorageException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } catch (error) {
      return BackendResponse(success: false, payload: error);
    }
  }

  static String getCurrentUsername() {
    if (_client.auth.currentUser == null &&
        _client.auth.currentUser!.userMetadata == null &&
        _client.auth.currentUser!.userMetadata!['username'] == null) return 'No user';

    return _client.auth.currentUser!.userMetadata!['username'];
  }

  static Future<BackendResponse> getUserProfile(String id) async {
    try {
      final Map<String, dynamic> response = await _client.from('profiles').select().eq('id', id).single();

      return BackendResponse(
        success: response.isNotEmpty,
        payload: Profile.fromMap(response),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> searchUsers(String query) async {
    final String userId = _client.auth.currentUser!.id;

    final List<Map<String, dynamic>> response =
        await _client.from('profiles').select().neq('id', userId).ilike('username', '%$query%').limit(10);

    final List<Profile> profiles = response
        .map(
          (element) => Profile.fromMap(element),
        )
        .toList();

    return BackendResponse(
      success: true,
      payload: profiles,
    );
  }

  static Future<BackendResponse> respondToInvitation(Membership invitation, bool accept) async {
    final Map<String, dynamic> response = await _client
        .from('memberships')
        .update({
          'accepted': accept,
          'joined_at': 'now()',
        })
        .eq('id', invitation.id)
        .select()
        .single();

    return BackendResponse(success: response.isNotEmpty, payload: response);
  }

  static Future<BackendResponse> getMembershipByID(String id) async {
    try {
      final Map<String, dynamic> response = await _client
          .from('memberships')
          .select(
            '*, communities(*), profiles(*)',
          )
          .eq('id', id)
          .single();

      if (response.isNotEmpty) {
        return BackendResponse(
          success: true,
          payload: Membership.fromMap(response),
        );
      } else {
        return BackendResponse(success: false, payload: 'Could not find membership with this ID.');
      }
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getInvitationsCountForUser() async {
    final String userId = _client.auth.currentUser!.id;

    final PostgrestResponse<PostgrestList> response = await _client
        .from('memberships')
        .select('*')
        .eq('member', userId)
        .isFilter('accepted', null)
        .count(CountOption.exact);

    return BackendResponse(
      success: true,
      payload: response.count,
    );
  }

  static Future<BackendResponse> getInvitationsForUser() async {
    final String userId = _client.auth.currentUser!.id;

    final List<Map<String, dynamic>> unconfirmedMemberships = await _client
        .from('memberships')
        .select('*, communities(*), profiles(*)')
        .eq('member', userId)
        .isFilter('accepted', null);

    final List<Membership> invitationsList = unconfirmedMemberships
        .map(
          (element) => Membership.fromMap(element),
        )
        .toList();

    return BackendResponse(
      success: invitationsList.isNotEmpty,
      payload: invitationsList,
    );
  }

  static Future<BackendResponse> changeUserAdminStatus(Community community, Profile user, bool shouldBeAdmin) async {
    try {
      final List<dynamic> updateMembershipResponse = await _client.from('memberships').update(
        {
          'is_admin': shouldBeAdmin,
        },
      ).match(
        {
          'member': user.id,
          'community': community.id,
        },
      ).select();

      return BackendResponse(
        success: updateMembershipResponse.isNotEmpty,
        payload: updateMembershipResponse,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(
        success: false,
        payload: error.message,
      );
    }
  }

  // TODO: Build the checking logic in the backend and remove the first half of this function.
  static Future<BackendResponse> inviteUserToCommunity(Community community, Profile user) async {
    final Map<String, dynamic>? memberExistsResponse = await _client.from('memberships').select().match({
      'community': community.id,
      'member': user.id,
    }).maybeSingle();

    if (memberExistsResponse != null) {
      if (memberExistsResponse['accepted'] != null && memberExistsResponse['accepted']) {
        return BackendResponse(
          success: false,
          payload: 'User is already a member in this community.',
        );
      } else {
        return BackendResponse(
          success: false,
          payload: 'User has already been invited to this community.',
        );
      }
    }

    final Map<String, dynamic> createMembershipResponse = await _client
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
    try {
      final List<dynamic> response = await _client.from('memberships').delete().match(
        {
          'member': user.id,
          'community': community.id,
        },
      ).select();

      return BackendResponse(
        success: response.isNotEmpty,
        payload: response,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(
        success: false,
        payload: error.message,
      );
    }
  }

  static Future<BackendResponse> removeCurrentUserFromCommunity(Community community) async {
    final String userId = _client.auth.currentUser!.id;

    final Map<String, dynamic>? memberExistsResponse = await _client.from('memberships').select().match({
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

    final Map<String, dynamic> deleteMembershipResponse = await _client
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
    final List<dynamic> membershipResponse =
        await _client.from('memberships').select('id, is_admin, profiles(id, username, show_email)').match(
      {
        'community': community.id,
        'accepted': true,
      },
    );

    final List<Profile> listOfProfiles = membershipResponse
        .map(
          (e) => Profile.fromMap(e['profiles']),
        )
        .toList();

    return BackendResponse(
      success: listOfProfiles.isNotEmpty,
      payload: listOfProfiles,
    );
  }
}
