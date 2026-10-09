class BackendResponse<ResponseType> {
  bool success = false;
  ResponseType? payload;
  String? error;

  BackendResponse({
    required this.success,
    this.payload,
    this.error,
  });
}

extension BackendResponseError on BackendResponse {
  /// Why the request failed, for the user: the error, a message left in
  /// the payload, or a generic one (a translation key).
  String get errorMessage {
    final String? message =
        error ?? (payload is String ? payload as String : null);
    return message == null || message.isEmpty ? 'Server error.' : message;
  }
}
