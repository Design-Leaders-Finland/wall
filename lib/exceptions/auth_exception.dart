// Custom exception for better error handling in authentication
class AuthFailedException implements Exception {
  final String message;
  final dynamic originalError;

  AuthFailedException(this.message, [this.originalError]);

  @override
  String toString() => message;
}
