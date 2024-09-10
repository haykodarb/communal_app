// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
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

      FileInfo? file =
          await DefaultCacheManager().getFileFromCache(community.image_path!);

      Uint8List bytes;

      if (file != null) {
        bytes = await file.file.openRead().toBytes();
      } else {
        bytes = await _client.storage
            .from('community_avatars')
            .download(community.image_path!);

        await DefaultCacheManager()
            .putFile(community.image_path!, bytes, key: community.image_path!);
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
          .eq('accepted', true)
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

  static Future<BackendResponse> getCommunitiesForUser() async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final List<dynamic> response =
          await _client.from('memberships').select('*, communities(*)').match(
        {
          'member': userId,
          'accepted': true,
        },
      ).order(
        'joined_at',
        ascending: false,
      );

      if (response.isEmpty) {
        return BackendResponse(
            success: false,
            payload: 'You have not joined any communities yet.');
      }

      final List<Community> listOfCommunities = response
          .map(
            (dynamic element) => Community(
              name: element['communities']['name'],
              id: element['communities']['id'],
	      description: element['communities']['description'],
              image_path: element['communities']['image_path'],
              owner: element['communities']['owner'],
              user_count: element['communities']['user_count'],
              isCurrentUserAdmin: element['is_admin'],
            ),
          )
          .toList();

      return BackendResponse(success: true, payload: listOfCommunities);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> updateCommunity(
    Community community,
    File? image,
  ) async {
    try {
      final String userId = UsersBackend.currentUserId;

      print(community.isCurrentUserOwner);
      if (!community.isCurrentUserOwner) {
        return BackendResponse(
          success: false,
          payload: 'Only owner can modify Community',
        );
      }
      String? pathToUpload = community.image_path;

      if (image != null) {
        final String imageExtension = image.path.split('.').last;

        final String currentTime =
            DateTime.now().millisecondsSinceEpoch.toString();

        pathToUpload = '/$userId/$currentTime.$imageExtension';

        String pathResponse =
            await _client.storage.from('community_avatars').upload(
                  pathToUpload,
                  image,
                  retryAttempts: 5,
                );

        if (!pathResponse.isImageFileName) {
          community.image_path = pathToUpload;

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
          .select()
          .maybeSingle();

      if (updateResponse == null || updateResponse.isEmpty) {
        return BackendResponse(
          success: false,
          payload: 'Server error, could not save changes.',
        );
      }

      return BackendResponse(
        success: true,
        payload: community,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } on StorageException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> createCommunity(
      Community community, File? image) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final String? imageExtension = image?.path.split('.').last;

      final String currentTime =
          DateTime.now().millisecondsSinceEpoch.toString();

      final String? pathToUpload =
          image == null ? null : '/$userId/$currentTime.$imageExtension';

      if (pathToUpload != null && image != null) {
        await _client.storage.from('community_avatars').upload(
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
              'owner': userId,
              'image_path': pathToUpload,
            },
          )
          .select()
          .single();

      if (createCommunityResponse.isNotEmpty) {
        return BackendResponse(
          success: createCommunityResponse.isNotEmpty,
          payload: createCommunityResponse,
        );
      }

      return BackendResponse(
        success: false,
        payload: 'Could not create community, please try again.',
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    } on StorageException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> deleteCommunity(Community community) async {
    try {
      final Map<String, dynamic> createCommunityResponse = await _client
          .from('communities')
          .delete()
          .eq('id', community.id)
          .select()
          .single();

      return BackendResponse(
        success: createCommunityResponse.isNotEmpty,
        payload: createCommunityResponse,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }
}
