import 'package:supabase_flutter/supabase_flutter.dart';

class RealtimeMessage {
  final String table;
  final Map<String, dynamic> new_row;
  final PostgresChangeEvent eventType;

  RealtimeMessage({
    required this.table,
    required this.new_row,
    required this.eventType,
  });
}
