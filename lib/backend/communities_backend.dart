// ignore_for_file: unnecessary_null_comparison
import 'dart:typed_data';
import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunitiesBackend {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<Uint8List?> getCommunityAvatar(Community community) async {
    try {
      if (community.image_path == null) {
        return null;
      }

      FileInfo? file = await DefaultCacheManager().getFileFromCache(community.image_path!);

      Uint8List bytes;

      if (file != null) {
        bytes = await file.file.openRead().toBytes();
      } else {
        bytes = await _client.storage.from('community_avatars').download(community.image_path!);

        await DefaultCacheManager().putFile(community.image_path!, bytes, key: community.image_path!);
      }

      return bytes;
    } catch (error) {
      return null;
    }
  }

  static Future<BackendResponse> getUserCountForCommunity(
    String communityId,
  ) async {
    try {
      final PostgrestResponse response = await _client
          .from('memberships')
          .select('id')
          .eq('community', communityId)
          .eq('member_accepted', true)
          .eq('admin_accepted', true)
          .count(CountOption.exact);

      if (response.count <= 0) {
        return BackendResponse(
          success: false,
          payload: 'Could not fetch user count.',
        );
      }

      return BackendResponse(
        success: true,
        payload: response.count,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getCommunityById(String id) async {
    try {
      final Map<String, dynamic>? response =
          await _client.from('communities').select('*, profiles(*)').eq('id', id).maybeSingle();

      if (response == null || response.isEmpty) {
        return BackendResponse(
          success: false,
          payload: 'No such community exists.',
        );
      }
      Community community = Community.fromMap(response);

      final Map<String, dynamic>? membershipResponse = await _client.from('memberships').select('*').match(
        {
          'member': UsersBackend.currentUserId,
          'community': id,
          'member_accepted': true,
          'admin_accepted': true,
        },
      ).maybeSingle();

      community.isCurrentUserAdmin = membershipResponse != null && membershipResponse['is_admin'];

      return BackendResponse(
        success: true,
        payload: community,
      );
    } catch (error) {
      return BackendResponse(success: false, payload: error);
    }
  }

  static Future<BackendResponse> searchAllCommunities({
    required int pageKey,
    required int pageSize,
    required String query,
  }) async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('communities')
          .select('*, profiles(*)')
          .ilike('name', '%$query%')
          .range(pageKey, pageKey + pageSize - 1);

      final List<Community> communities =
          response.map((Map<String, dynamic> element) => Community.fromMap(element)).toList();

      return BackendResponse(success: true, payload: communities);
    } catch (e) {
      return BackendResponse(success: false);
    }
  }

  static Future<BackendResponse> getCommunitiesForCurrentUser({
    required int pageSize,
    required int pageKey,
  }) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final List<dynamic> response = await _client
          .from('memberships')
          .select('*, communities(*, profiles(*))')
          .match(
            {
              'member': userId,
              'member_accepted': true,
              'admin_accepted': true,
            },
          )
          .order(
            'joined_at',
            ascending: false,
          )
          .range(pageKey, pageKey + pageSize - 1);

      if (response.isEmpty) {
        return BackendResponse(
          success: false,
          payload:
              'You have not joined any communities yet.\nGet started by creating your own or asking someone for an invitation.',
        );
      }

      final List<Community> listOfCommunities = response
          .map(
            (dynamic element) => Community.fromMembershipMap(element),
          )
          .toList();

      return BackendResponse(success: true, payload: listOfCommunities);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> updateCommunity(
    Community community,
    Uint8List? imageBytes,
  ) async {
    try {
      final String userId = UsersBackend.currentUserId;

      if (!community.isCurrentUserOwner) {
        return BackendResponse(
          success: false,
          payload: 'Only owner can modify Community',
        );
      }
      String? pathToUpload = community.image_path;

      if (imageBytes != null) {
        print('file size: ${imageBytes.length}');
        const String imageExtension = 'png';

        final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

        pathToUpload = '/$userId/$currentTime.$imageExtension';

        String pathResponse = await _client.storage.from('community_avatars').uploadBinary(
              pathToUpload,
              imageBytes,
              retryAttempts: 5,
            );

        if (!pathResponse.isImageFileName) {
          return BackendResponse(
            success: false,
            payload: 'Could not upload photo to server.',
          );
        }
      }

      final Map<String, dynamic>? updateResponse = await _client
          .from('communities')
          .update(
            {
              'name': community.name,
              'description': community.description,
              'image_path': pathToUpload,
            },
          )
          .eq('id', community.id)
          .select('*, profiles(*)')
          .maybeSingle();

      if (updateResponse == null || updateResponse.isEmpty) {
        return BackendResponse(
          success: false,
          payload: 'Server error, could not save changes.',
        );
      }

      return BackendResponse(
        success: true,
        payload: Community.fromMap(updateResponse),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    } on StorageException catch (error) {
      return BackendResponse(success: false, error: error.message);
    }
  }

  static Future<BackendResponse<Community>> createCommunity(Community community, Uint8List? image) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      const String imageExtension = '.png';

      final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

      final String? pathToUpload = image == null ? null : '/$userId/$currentTime.$imageExtension';

      if (pathToUpload != null && image != null) {
        await _client.storage.from('community_avatars').uploadBinary(
              pathToUpload,
              image,
              retryAttempts: 5,
            );
      }

      final Map<String, dynamic> createCommunityResponse = await _client
          .from('communities')
          .insert(
            {
              'name': community.name,
              'description': community.description,
              'owner': userId,
              'image_path': pathToUpload,
            },
          )
          .select('*, profiles(*)')
          .single();

      if (createCommunityResponse.isNotEmpty) {
        Community community = Community.fromMap(createCommunityResponse);
        community.isCurrentUserAdmin = true;

        return BackendResponse(
          success: true,
          payload: community,
        );
      }

      return BackendResponse(success: false, error: 'Server error');
    } catch (err) {
      return BackendResponse(success: false, error: err.toString());
    }
  }

  static Future<BackendResponse> deleteCommunity(Community community) async {
    try {
      final Map<String, dynamic> response =
          await _client.from('communities').delete().eq('id', community.id).select('*, profiles(*)').single();

      return BackendResponse(
        success: response.isNotEmpty,
        payload: response,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }
}
