class BackendResponse<ResponseType> {
  bool success = false;
  ResponseType payload;

  BackendResponse({
    required this.success,
    required this.payload,
  });
}
