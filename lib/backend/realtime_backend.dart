import 'dart:async';

import 'package:communal/models/realtime_message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeBackend {
  static final StreamController<RealtimeMessage> streamController = StreamController<RealtimeMessage>.broadcast();

  static void subscribeToDatabaseChanges() {
    final SupabaseClient client = Supabase.instance.client;

    client
        .channel(
          'all',
          opts: const RealtimeChannelConfig(
            self: true,
          ),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          callback: (PostgresChangePayload payload) {
            if (payload.newRecord.isNotEmpty || payload.oldRecord.isNotEmpty) {
              final RealtimeMessage realtimeMessage = RealtimeMessage(
                table: payload.table,
                new_row: payload.newRecord,
                old_row: payload.oldRecord,
                eventType: payload.eventType,
              );
              streamController.add(realtimeMessage);
            }
          },
        )
        .subscribe();
  }
}
