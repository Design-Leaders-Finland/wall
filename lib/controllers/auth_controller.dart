import '../services/auth_service.dart';
import '../exceptions/auth_exception.dart';
import '../utils/logger.dart';

/// Controller for managing authentication state and operations.
/// Handles both authenticated users and guest mode with session UUID system
/// for database operations (RFC 4122 compliant).
class AuthController {
  final AuthService _authService = AuthService();

  /// Gets the current authenticated user
  dynamic get currentUser => _authService.getCurrentUser();

  /// Attempts to sign in anonymously
  /// Returns null if falling back to guest mode
  Future<dynamic> signInAnonymously() async {
    try {
      final user = await _authService.signInAnonymously();

      if (user == null) {
        AppLogger.info('Running in guest mode');
      } else {
        AppLogger.info('Authentication successful for user: ${user.id}');
      }

      return user;
    } on AuthFailedException catch (e) {
      AppLogger.error('Authentication failed', e);
      rethrow;
    }
  }

  /// Determines the user ID to use for database operations (message sending).
  /// Returns a tuple of (userId, isGuest).
  ///
  /// For authenticated users: returns (user.id, false)
  /// For guest users: returns (sessionUUID, true) - uses RFC 4122 compliant UUID
  /// for database compatibility.
  (String, bool) getUserIdForMessaging() {
    final user = currentUser;

    if (user == null) {
      AppLogger.info(
        'No authenticated user, using guest mode for message sending',
      );
      // Use session UUID for database operations
      final sessionId = _authService.getSessionUserId();
      AppLogger.info(
        'Sending message as guest user with session UUID: $sessionId',
      );
      return (sessionId, true);
    } else {
      AppLogger.info('Sending message as authenticated user: ${user.id}');
      return (user.id, false);
    }
  }
}
