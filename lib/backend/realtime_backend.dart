import 'dart:async';

import 'package:communal/models/realtime_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeBackend {
  static final StreamController<RealtimeMessage> streamController = StreamController<RealtimeMessage>.broadcast();

  static Future<void> subscribeToDatabaseChanges() async {
    final SupabaseClient client = Supabase.instance.client;

    final RealtimeChannel channel = client
        .channel(
      'postgres_changes',
      opts: const RealtimeChannelConfig(
        self: true,
      ),
    )
        .on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: '*', schema: 'public'),
      (payload, [ref]) {
        switch (payload['eventType']) {
          case 'INSERT':
          case 'UPDATE':
            final RealtimeMessage message = RealtimeMessage(
              table: payload['table'],
              rowId: payload['new']['id'],
              eventType: payload['eventType'],
            );

            streamController.add(message);
            break;

          case 'DELETE':
            final RealtimeMessage message = RealtimeMessage(
              table: payload['table'],
              rowId: payload['old']['id'],
              eventType: payload['eventType'],
            );

            streamController.add(message);
            break;
          default:
            break;
        }
      },
    );

    channel.subscribe();
  }
}
