import 'package:communal/models/backend_response.dart';
import 'package:communal/models/discussion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscussionsBackend {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<BackendResponse> createDiscussionTopic({
    required String name,
    required String communityId,
  }) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final Map<String, dynamic>? response = await _client
          .from('discussion_topics')
          .insert({
            'creator': userId,
            'community': communityId,
            'name': name,
          })
          .select('*, profiles(*), communities(*, profiles(*))')
          .maybeSingle();

      if (response == null || response.isEmpty) {
        return BackendResponse(
          success: false,
          payload: 'Could not create topic.',
        );
      }

      return BackendResponse(
        success: true,
        payload: DiscussionTopic.fromMap(response),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getDiscussionTopicsForCommunity({
    required String communityId,
    required int pageKey,
    required int pageSize,
    required String query,
  }) async {
    try {
      final List<dynamic> response = await _client
          .from('discussion_topics')
          .select(
            '*, profiles(*), communities(*, profiles(*)), last_message(*, profiles(*))',
          )
          .eq(
            'community',
            communityId,
          )
          .ilike('name', '%$query%')
          .range(pageKey, pageKey + pageSize - 1);

      final List<DiscussionTopic> topics = response.map((element) => DiscussionTopic.fromMap(element)).toList();

      if (response.isEmpty) {
        return BackendResponse(success: false, payload: 'This community has no discussions yet');
      }

      return BackendResponse(
        success: response.isNotEmpty,
        payload: topics,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getDiscussionMessagesForTopic(String topicId) async {
    try {
      final List<dynamic> response = await _client
          .from('discussion_messages')
          .select(
            '*, profiles(*)',
          )
          .eq('topic', topicId)
          .order(
            'created_at',
            ascending: false,
          );

      if (response.isEmpty) {
        return BackendResponse(success: false, payload: 'No messages in topic');
      }

      final List<DiscussionMessage> messages = response.map((element) => DiscussionMessage.fromMap(element)).toList();

      return BackendResponse(
        success: messages.isNotEmpty,
        payload: messages,
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> insertDiscussionMessageInTopic(String topicId, String content) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final Map<String, dynamic>? response = await _client
          .from('discussion_messages')
          .insert({
            'sender': userId,
            'topic': topicId,
            'content': content,
          })
          .select(
            '*, profiles(*)',
          )
          .maybeSingle();

      if (response == null || response.isEmpty) {
        return BackendResponse(success: false, payload: 'Could not send message, please try again');
      }

      return BackendResponse(success: true, payload: DiscussionMessage.fromMap(response));
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getDiscussionMessageById(String id) async {
    try {
      final Map<String, dynamic>? response = await _client
          .from('discussion_messages')
          .select(
            '*, profiles(*)',
          )
          .eq('id', id)
          .maybeSingle();

      if (response == null || response.isEmpty) {
        return BackendResponse(success: false, payload: '');
      }

      return BackendResponse(
        success: true,
        payload: DiscussionMessage.fromMap(response),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }

  static Future<BackendResponse> getDiscussionTopicById(String id) async {
    try {
      final Map<String, dynamic>? response = await _client
          .from('discussion_topics')
          .select(
            '*, profiles(*), communities(*, profiles(*)), last_message(*, profiles(*))',
          )
          .eq('id', id)
          .maybeSingle();

      if (response == null || response.isEmpty) {
        return BackendResponse(success: false, payload: '');
      }

      return BackendResponse(
        success: true,
        payload: DiscussionTopic.fromMap(response),
      );
    } on PostgrestException catch (error) {
      return BackendResponse(success: false, payload: error.message);
    }
  }
}
