import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/discussion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscussionsBackend {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<BackendResponse> createDiscussionTopic({
    required String name,
    required Community community,
  }) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final Map<String, dynamic>? response = await _client
          .from('discussion_topics')
          .insert({
            'creator': userId,
            'community': community.id,
            'name': name,
          })
          .select('*, profiles(*), communities(*)')
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

  static Future<BackendResponse> getDiscussionTopicsForCommunity(Community community) async {
    try {
      final List<dynamic> response = await _client
          .from('discussion_topics')
          .select(
            '*, profiles(*), communities(*), last_message(*, profiles(*))',
          )
          .eq(
            'community',
            community.id,
          );

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

  static Future<BackendResponse> getDiscussionMessagesForTopic(DiscussionTopic topic) async {
    try {
      final List<dynamic> response = await _client
          .from('discussion_messages')
          .select(
            '*, profiles(*)',
          )
          .eq('topic', topic.id)
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

  static Future<BackendResponse> insertDiscussionMessageInTopic(DiscussionTopic topic, String content) async {
    try {
      final String userId = _client.auth.currentUser!.id;

      final Map<String, dynamic>? response = await _client
          .from('discussion_messages')
          .insert({
            'sender': userId,
            'topic': topic.id,
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
            '*, profiles(*), discussion_topics(*, profiles(*), communities(*))',
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
}
