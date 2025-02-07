import 'dart:typed_data';
import 'package:communal/backend/login_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/membership.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class UsersBackend {
  static final SupabaseClient _client = Supabase.instance.client;

  static String get currentUserId {
    return _client.auth.currentUser!.id;
  }

  static Future<bool> validateUsername(String username) async {
    final Map<String, dynamic>? foundUsername =
        await _client.from('profiles').select().eq('username', username).maybeSingle();

    return foundUsername == null || foundUsername.isEmpty;
  }

  static Future<bool> deleteUser() async {
    try {
      await _client.rpc(
        'delete_user',
        params: {
          "user_id": currentUserId,
        },
      );

      return true;
    } catch (e) {
      return false;
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

  static Future<BackendResponse> updateProfile(
    Profile profile,
    Uint8List? image,
  ) async {
    try {
      final String userId = _client.auth.currentUser!.id;
      final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

      String? fileName;

      if (image != null) {
        const String imageExtension = 'png';

        fileName = '/$userId/$currentTime.$imageExtension';

        await _client.storage.from('profile_avatars').uploadBinary(
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
        _client.auth.currentUser!.userMetadata!['username'] == null) {
      return 'No user';
    }

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

  static Future<BackendResponse> searchAllUsers({
    required int pageKey,
    required int pageSize,
    required String query,
  }) async {
    try {
      final List<Map<String, dynamic>> response =
          await _client.from('profiles').select().ilike('username', '%$query%').range(pageKey, pageKey + pageSize - 1);

      final List<Profile> profiles = response.map((Map<String, dynamic> element) => Profile.fromMap(element)).toList();

      return BackendResponse(payload: profiles, success: true);
    } catch (e) {
      return BackendResponse(success: false);
    }
  }

  static Future<BackendResponse> searchUsersNotInCommunity({
    required String communityId,
    required String query,
    required int pageKey,
    required int pageSize,
  }) async {
    final List<Map<String, dynamic>> response = await _client.rpc(
      'get_users_not_in_community',
      params: {
        'community_id': communityId,
        'search_query': query,
        'offset_num': pageKey,
        'limit_num': 20,
      },
    );

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

  static Future<BackendResponse> respondToInvitation(
    String membershipId,
    bool accept,
  ) async {
    final Map<String, dynamic>? response = await _client
        .from('memberships')
        .update({
          'member_accepted': accept,
          'joined_at': 'now()',
        })
        .eq('id', membershipId)
        .select()
        .maybeSingle();

    return BackendResponse(
      success: response?.isNotEmpty ?? false,
      payload: response,
    );
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
        .isFilter('member_accepted', null)
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
        .isFilter('member_accepted', null);

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

  static Future<BackendResponse> changeUserAdminStatus(String communityId, Profile user, bool shouldBeAdmin) async {
    try {
      final List<dynamic> updateMembershipResponse = await _client.from('memberships').update(
        {
          'is_admin': shouldBeAdmin,
        },
      ).match(
        {
          'member': user.id,
          'community': communityId,
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

  static Future<BackendResponse> requestInviteToCommunity(
    String communityId,
  ) async {
    try {
      final Map<String, dynamic> createMembershipResponse = await _client
          .from('memberships')
          .insert(
            {
              'member': UsersBackend.currentUserId,
              'community': communityId,
              'is_admin': false,
              'member_accepted': true,
            },
          )
          .select('*, profiles(*), communities(*)')
          .single();

      if (createMembershipResponse.isEmpty) {
        return BackendResponse(success: false, payload: 'Error in sending out invitation.');
      }

      return BackendResponse(
        success: true,
        payload: Membership.fromMap(createMembershipResponse),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> inviteUserToCommunity(
    String communityId,
    Profile user,
  ) async {
    try {
      final Map<String, dynamic> createMembershipResponse = await _client
          .from('memberships')
          .insert(
            {
              'member': user.id,
              'community': communityId,
              'is_admin': false,
              'admin_accepted': true,
            },
          )
          .select('*, profiles(*), communities(*)')
          .single();

      if (createMembershipResponse.isEmpty) {
        return BackendResponse(success: false, payload: 'Error in sending out invitation.');
      }

      return BackendResponse(
        success: true,
        payload: Membership.fromMap(createMembershipResponse),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> removeUserFromCommunity(
    String communityId,
    String userId,
  ) async {
    try {
      final List<dynamic> response = await _client.from('memberships').delete().match(
        {
          'member': userId,
          'community': communityId,
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

  static Future<BackendResponse> removeCurrentUserFromCommunity(
    Community community,
  ) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final Map<String, dynamic>? deleteMembershipResponse = await _client
          .from('memberships')
          .delete()
          .match(
            {
              'member': userId,
              'community': community.id,
              'member_accepted': true,
            },
          )
          .select()
          .maybeSingle();

      return BackendResponse(
        success: deleteMembershipResponse?.isNotEmpty ?? false,
        payload: deleteMembershipResponse,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse<List<Profile>>> getUsersInCommunity({
    required String communityId,
    required int pageKey,
    required int pageSize,
    required String query,
  }) async {
    try {
      final List<dynamic> membershipResponse = await _client
          .from('memberships')
          .select('*, profiles(*)')
          .match(
            {
              'community': communityId,
              'member_accepted': true,
              'admin_accepted': true,
            },
          )
          .ilike('profiles.username', '%$query%')
          .range(pageKey, pageKey + pageSize - 1);

      final List<Profile> listOfProfiles = membershipResponse.map(
        (e) {
          Profile profile = Profile.fromMap(e['profiles']);
          profile.is_admin = e['is_admin'];

          return profile;
        },
      ).toList();

      return BackendResponse(
        success: listOfProfiles.isNotEmpty,
        payload: listOfProfiles.isNotEmpty ? listOfProfiles : null,
      );
    } catch (e) {
      return BackendResponse(success: false);
    }
  }
}
