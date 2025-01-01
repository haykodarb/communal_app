class BackendResponse<ResponseType> {
  bool success = false;
  ResponseType? payload;

  BackendResponse({
    required this.success,
    this.payload,
  });
}
