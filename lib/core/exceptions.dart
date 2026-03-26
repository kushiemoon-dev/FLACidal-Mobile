/// Exception thrown by the FLACidal core bridge.
class FlacCoreException implements Exception {
  final String code;
  final String message;

  const FlacCoreException({required this.code, required this.message});

  @override
  String toString() => 'FlacCoreException($code): $message';
}
