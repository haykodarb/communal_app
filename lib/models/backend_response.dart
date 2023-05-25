import 'dart:convert';

class BackendReponse {
  bool success = false;
  dynamic payload;

  BackendReponse({
    required this.success,
    required this.payload,
  });

  BackendReponse.fromBody(String body) {
    Map<String, dynamic> parsedBody = jsonDecode(body);
    success = parsedBody['success'];
    payload = parsedBody['payload'];
  }
}
