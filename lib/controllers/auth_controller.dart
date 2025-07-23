import '../services/auth_service.dart';
import '../exceptions/auth_exception.dart';
import '../utils/logger.dart';

/// Controller for managing authentication state and operations
class AuthController {
  final AuthService _authService = AuthService();

  /// Gets the current authenticated user
  get currentUser => _authService.getCurrentUser();

  /// Gets a guest user ID for offline mode
  String getGuestUserId() => _authService.getGuestUserId();

  /// Attempts to sign in anonymously
  /// Returns null if falling back to guest mode
  Future<dynamic> signInAnonymously() async {
    try {
      final user = await _authService.signInAnonymously();

      if (user == null) {
        AppLogger.info(
          'Running in guest mode - messages will be stored locally only',
        );
      } else {
        AppLogger.info('Authentication successful for user: ${user.id}');
      }

      return user;
    } on AuthFailedException catch (e) {
      AppLogger.error('Authentication failed', e);
      rethrow;
    }
  }

  /// Determines the user ID to use for message sending
  /// Returns a tuple of (userId, isGuest)
  (String, bool) getUserIdForMessaging() {
    final user = currentUser;

    if (user == null) {
      AppLogger.info(
        'No authenticated user, using guest mode for message sending',
      );
      final guestId = getGuestUserId();
      AppLogger.info('Sending message as guest user: $guestId');
      return (guestId, true);
    } else {
      AppLogger.info('Sending message as authenticated user: ${user.id}');
      return (user.id, false);
    }
  }
}
