class PlatformChannelException implements Exception {
  final String code;
  final String? message;
  final dynamic details;

  PlatformChannelException(this.code, [this.message, this.details]);

  @override
  String toString() => 'PlatformChannelException($code, $message, $details)';
}

