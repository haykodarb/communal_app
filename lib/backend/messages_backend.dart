import 'package:communal/models/backend_response.dart';
import 'package:communal/models/message.dart';
import 'package:communal/models/profile.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesBackend {
  static Future<BackendResponse> submitMessage(Profile receiver, String content) async {
    final SupabaseClient client = Supabase.instance.client;
    final String userId = client.auth.currentUser!.id;

    final Map<String, dynamic> response = await client
        .from('messages')
        .insert(
          {
            'sender': userId,
            'receiver': receiver.id,
            'content': content,
          },
        )
        .select()
        .single();

    return BackendResponse(
      success: response.isNotEmpty,
      payload: response,
    );
  }

  static Future<BackendResponse> getDistinctChats() async {
    final SupabaseClient client = Supabase.instance.client;

    final List<Map<String, dynamic>> distinctChats = await client
        .from('distinct_chats')
        .select('*, receiver_profile:profiles!receiver(*),sender_profile:profiles!sender(*)');

    final List<Message> messages = <Message>[];

    for (Map<String, dynamic> chat in distinctChats) {
      final Message message = Message.fromMap(chat);

      final bool shouldAdd = !distinctChats.any(
        (Map<String, dynamic> element) {
          final bool chatExists = element['sender'] == message.receiver.id && element['receiver'] == message.sender.id;

          final bool chatIsMoreRecent = message.created_at.compareTo(DateTime.parse(element['created_at'])) < 0;

          return chatExists && chatIsMoreRecent;
        },
      );

      if (shouldAdd) {
        messages.add(message);
      }
    }

    return BackendResponse(
      success: messages.isNotEmpty,
      payload: messages,
    );
  }

  static Future<BackendResponse> getMessagesWithUser(Profile user) async {
    final SupabaseClient client = Supabase.instance.client;
    final String currentUserId = client.auth.currentUser!.id;

    final String filter =
        'and(sender.eq.$currentUserId, receiver.eq.${user.id}), and(sender.eq.${user.id}, receiver.eq.$currentUserId)';

    final List<dynamic> response = await client
        .from('messages')
        .select('*, receiver_profile:profiles!receiver(*),sender_profile:profiles!sender(*)')
        .or(filter)
        .limit(100)
        .order(
          'created_at',
          ascending: true,
        );

    final List<Message> listOfMessages = response.map(
      (element) {
        return Message.fromMap(element);
      },
    ).toList();

    return BackendResponse(
      success: listOfMessages.isNotEmpty,
      payload: listOfMessages,
    );
  }

  static RealtimeChannel subscribeToMessagesWithUser(Profile user, void Function(Message) callback) {
    final SupabaseClient client = Supabase.instance.client;

    RealtimeChannel channel = client
        .channel(
      'public:messages',
      opts: const RealtimeChannelConfig(self: true),
    )
        .on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'messages'),
      (payload, [ref]) {
        final Map<String, dynamic> response = payload['new'];

        callback(
          Message(
            id: response['id'],
            created_at: DateTime.parse(response['created_at']),
            content: response['content'],
            sender: Profile(
              id: response['sender'],
              username: '',
            ),
            receiver: Profile(
              id: response['receiver'],
              username: '',
            ),
            is_read: response['is_read'],
          ),
        );
      },
    );

    return channel;
  }
}
