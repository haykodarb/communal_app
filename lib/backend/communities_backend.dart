import 'dart:io';
import 'dart:typed_data';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CommunitiesBackend {
  static Future<Uint8List> getCommunityAvatar(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    if (community.image_path != null) {
      Uint8List bytes = await client.storage.from('community_avatars').download(community.image_path!);
      return bytes;
    }

    return Uint8List(0);
  }

  static Future<BackendResponse> getCommunitiesForUser() async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final List<dynamic> response = await client
        .from('memberships')
        .select('id, created_at, joined_at, member, is_admin, accepted, communities(id, name, owner, image_path)')
        .match({
      'member': userId,
      'accepted': true,
    }).order(
      'joined_at',
      ascending: true,
    );

    if (response.isEmpty) {
      return BackendResponse(success: false, payload: null);
    }

    print(response);

    final List<Community> listOfCommunities = response
        .map(
          (dynamic element) => Community(
            name: element['communities']['name'],
            id: element['communities']['id'],
            image_path: element['communities']['image_path'],
            owner: element['communities']['owner'],
            isCurrentUserAdmin: element['is_admin'],
          ),
        )
        .toList();

    return BackendResponse(success: true, payload: listOfCommunities);
  }

  static Future<BackendResponse> createCommunity(Community community, File? image) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final String? imageExtension = image?.path.split('.').last;

    final String currentTime = DateTime.now().millisecondsSinceEpoch.toString();

    final String? pathToUpload = image == null ? null : '/$userId/$currentTime.$imageExtension';

    if (pathToUpload != null && image != null) {
      await client.storage.from('community_avatars').upload(
            pathToUpload,
            image,
            retryAttempts: 5,
          );
    }

    final Map<String, dynamic> createCommunityResponse = await client
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
  }

  static Future<BackendResponse> deleteCommunity(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic> createCommunityResponse =
        await client.from('communities').delete().eq('id', community.id).select().single();

    return BackendResponse(
      success: createCommunityResponse.isNotEmpty,
      payload: createCommunityResponse,
    );
  }
}
