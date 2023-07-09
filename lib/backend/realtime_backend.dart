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
        if (payload.isNotEmpty) {
          final RealtimeMessage realtimeMessage = RealtimeMessage(
            table: payload['table'],
            new_row: payload['new'],
            eventType: payload['eventType'],
          );

          streamController.add(realtimeMessage);
        }
      },
    );

    channel.subscribe();
  }
}
