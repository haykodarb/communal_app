import 'package:communal/backend/users_backend.dart';
import 'package:communal/models/backend_response.dart';
import 'package:communal/models/community.dart';
import 'package:communal/models/discussion.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscussionsBackend {
  static Future<BackendResponse> createDiscussionTopic({
    required String name,
    required Community community,
  }) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic>? response = await client
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
  }

  static Future<BackendResponse> getDiscussionTopicsForCommunity(Community community) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<dynamic> response = await client
        .from('discussion_topics')
        .select(
          '*, profiles(*), communities(*)',
        )
        .eq(
          'community',
          community.id,
        );

    final List<DiscussionTopic> topics = response.map((element) => DiscussionTopic.fromMap(element)).toList();

    return BackendResponse(
      success: response.isNotEmpty,
      payload: topics,
    );
  }

  static Future<BackendResponse> getDiscussionMessagesForTopic(DiscussionTopic topic) async {
    final SupabaseClient client = Supabase.instance.client;

    final List<dynamic> response = await client
        .from('discussion_messages')
        .select(
          '*, profiles(*), discussion_topics(*, profiles(*), communities(*))',
        )
        .eq('topic', topic.id)
        .order(
          'created_at',
          ascending: false,
        );

    if (response.isEmpty) {
      return BackendResponse(success: false, payload: []);
    }

    final List<DiscussionMessage> messages = response.map((element) => DiscussionMessage.fromMap(element)).toList();

    return BackendResponse(
      success: messages.isNotEmpty,
      payload: messages,
    );
  }

  static Future<BackendResponse> insertDiscussionMessageInTopic(DiscussionTopic topic, String content) async {
    final SupabaseClient client = Supabase.instance.client;

    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic>? response = await client
        .from('discussion_messages')
        .insert({
          'sender': userId,
          'topic': topic.id,
          'content': content,
        })
        .select(
          '*, profiles(*), discussion_topics(*, profiles(*), communities(*))',
        )
        .maybeSingle();

    if (response == null || response.isEmpty) {
      return BackendResponse(success: false, payload: 'Could not send message');
    }

    return BackendResponse(success: true, payload: DiscussionMessage.fromMap(response));
  }

  static Future<BackendResponse> getDiscussionMessageById(String id) async {
    final SupabaseClient client = Supabase.instance.client;

    final Map<String, dynamic>? response = await client
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
  }

  static RealtimeChannel subscribeToTopicMessages(
    void Function(DiscussionMessage) callback,
    DiscussionTopic topic,
  ) {
    final SupabaseClient client = Supabase.instance.client;

    RealtimeChannel channel = client
        .channel(
      'public:discussion_messages',
    )
        .on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public', table: 'discussion_messages'),
      (payload, [ref]) async {
        final Map<String, dynamic> newMessage = payload['new'];

        if (newMessage.isEmpty) return;

        if (newMessage['topic'] != topic.id) return;

        if (newMessage['sender'] == UsersBackend.getCurrentUserId()) return;

        final BackendResponse response = await DiscussionsBackend.getDiscussionMessageById(
          newMessage['id'],
        );

        if (response.success) {
          callback(response.payload);
        }
      },
    );

    return channel;
  }
}
