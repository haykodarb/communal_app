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
