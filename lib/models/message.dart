class Message {
  final String id;
  final DateTime created_at;
  final String sender;
  final String receiver;
  final String content;
  final bool is_read;

  Message({
    required this.id,
    required this.created_at,
    required this.sender,
    required this.receiver,
    required this.content,
    required this.is_read,
  });

  Message.fromMap(Map<String, dynamic> map)
      : sender = map['sender'],
        receiver = map['receiver'],
        content = map['content'],
        created_at = DateTime.parse(map['created_at']),
        is_read = map['is_read'],
        id = map['id'];

  // Message.empty()
  //     : id = '',
  //       created_at = DateTime.now(),
  //       sender = Profile.,
  //       receiver = Profile.,
  //       content = '',
  //       is_read = false;
}
