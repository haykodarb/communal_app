class RealtimeMessage {
  final String table;
  final Map<String, dynamic> new_row;
  final String eventType;

  RealtimeMessage({
    required this.table,
    required this.new_row,
    required this.eventType,
  });
}
