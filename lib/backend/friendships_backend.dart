import 'package:communal/models/backend_response.dart';
import 'package:communal/models/friendship.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FriendshipsBackend {
  static final SupabaseClient _client = Supabase.instance.client;

  static String get currentUserId {
    return _client.auth.currentUser!.id;
  }

  static Future<BackendResponse<Friendship?>> getFriendshipWithUser(
      String otherUserId) async {
    try {
      final Map<String, dynamic>? friendship = await _client
          .from('friendships')
          .select(
              '*, requester_profile:profiles!requester(*), responder_profile:profiles!responder(*)')
          .or('and(requester.eq.$currentUserId,responder.eq.$otherUserId),and(requester.eq.$otherUserId,responder.eq.$currentUserId)')
          .maybeSingle();

      if (friendship == null) {
        return BackendResponse(success: true, payload: null);
      }

      print(friendship);
      return BackendResponse(
        success: true,
        payload: Friendship.fromMap(friendship),
      );
    } on PostgrestException catch (error) {
      print(error);
      return BackendResponse(success: false, error: error.message);
    } catch (error) {
      print(error);
      return BackendResponse(success: false, error: error.toString());
    }
  }

  static Future<BackendResponse<Friendship>> sendFriendRequest(
    String targetUserId,
  ) async {
    try {
      if (targetUserId == currentUserId) {
        return BackendResponse(
          success: false,
          error: 'Cannot send friend request to yourself.',
        );
      }

      final Map<String, dynamic>? existingFriendship = await _client
          .from('friendships')
          .select('*')
          .or(
            'and(requester.eq.$currentUserId,responder.eq.$targetUserId),and(requester.eq.$targetUserId,responder.eq.$currentUserId)',
          )
          .maybeSingle();

      if (existingFriendship != null) {
        return BackendResponse(
          success: false,
          error: 'Friendship already exists.',
        );
      }

      final Map<String, dynamic> createResponse = await _client
          .from('friendships')
          .insert({
            'requester': currentUserId,
            'responder': targetUserId,
            'accepted': null,
          })
          .select(
            '*, requester_profile:profiles!requester(*), responder_profile:profiles!responder(*)',
          )
          .single();

      return BackendResponse(
        success: true,
        payload: Friendship.fromMap(createResponse),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    } catch (error) {
      return BackendResponse(success: false, error: error.toString());
    }
  }

  static Future<BackendResponse<List<Friendship>>> getPendingRequests({
    required int pageKey,
    required int pageSize,
  }) async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('friendships')
          .select(
              '*, requester_profile:profiles!requester(*), responder_profile:profiles!responder(*)')
          .isFilter('accepted', null)
          .eq('responder', currentUserId)
          .order('created_at', ascending: false)
          .range(pageKey, pageKey + pageSize - 1);

      final List<Friendship> requests =
          response.map((el) => Friendship.fromMap(el)).toList();

      return BackendResponse(success: true, payload: requests);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    } catch (error) {
      return BackendResponse(success: false, error: error.toString());
    }
  }

  static Future<BackendResponse<List<Friendship>>> getSentRequests({
    required int pageKey,
    required int pageSize,
  }) async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('friendships')
          .select(
              '*, requester_profile:profiles!requester(*), responder_profile:profiles!responder(*)')
          .isFilter('accepted', null)
          .eq('requester', currentUserId)
          .order('created_at', ascending: false)
          .range(pageKey, pageKey + pageSize - 1);

      final List<Friendship> requests =
          response.map((el) => Friendship.fromMap(el)).toList();

      return BackendResponse(success: true, payload: requests);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    } catch (error) {
      return BackendResponse(success: false, error: error.toString());
    }
  }

  static Future<BackendResponse<Friendship>> respondToFriendRequest({
    required String friendshipId,
    required bool accept,
  }) async {
    try {
      final Map<String, dynamic> updateResponse = await _client
          .from('friendships')
          .update({
            'accepted': accept,
            'accepted_at': 'now()',
          })
          .eq('id', friendshipId)
          .select(
              '*, requester_profile:profiles!requester(*), responder_profile:profiles!responder(*)')
          .single();

      return BackendResponse(
        success: true,
        payload: Friendship.fromMap(updateResponse),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    } catch (error) {
      return BackendResponse(success: false, error: error.toString());
    }
  }

  static Future<BackendResponse<List<Friendship>>> getFriends({
    required int pageKey,
    required int pageSize,
  }) async {
    try {
      final List<Map<String, dynamic>> response = await _client
          .from('friendships')
          .select(
            '*, requester_profile:profiles!requester(*), responder_profile:profiles!responder(*)',
          )
          .eq('accepted', true)
          .or('requester.eq.$currentUserId,responder.eq.$currentUserId')
          .order('accepted_at', ascending: false)
          .range(pageKey, pageKey + pageSize - 1);

      final List<Friendship> friends =
          response.map((el) => Friendship.fromMap(el)).toList();

      return BackendResponse(success: true, payload: friends);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    } catch (error) {
      return BackendResponse(success: false, error: error.toString());
    }
  }

  static Future<BackendResponse> deleteFriendship(String friendshipId) async {
    try {
      await _client.from('friendships').delete().eq('id', friendshipId);

      return BackendResponse(success: true);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    } catch (error) {
      return BackendResponse(success: false, error: error.toString());
    }
  }

  static Future<BackendResponse<int>> getPendingRequestsCount() async {
    try {
      final PostgrestResponse response = await _client
          .from('friendships')
          .select('*')
          .isFilter('accepted', null)
          .eq('responder', currentUserId)
          .count(CountOption.exact);

      return BackendResponse(success: true, payload: response.count);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    } catch (error) {
      return BackendResponse(success: false, error: error.toString());
    }
  }

  static Future<BackendResponse<int>> getFriendsCount() async {
    try {
      final PostgrestResponse response = await _client
          .from('friendships')
          .select('*')
          .eq('accepted', true)
          .or('requester.eq.$currentUserId,responder.eq.$currentUserId')
          .count(CountOption.exact);

      return BackendResponse(success: true, payload: response.count);
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, error: error.message);
    } catch (error) {
      return BackendResponse(success: false, error: error.toString());
    }
  }
}
