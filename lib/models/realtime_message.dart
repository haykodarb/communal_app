class RealtimeMessage {
  final String table;
  final String rowId;
  final String eventType;

  RealtimeMessage({
    required this.table,
    required this.rowId,
    required this.eventType,
  });
}
