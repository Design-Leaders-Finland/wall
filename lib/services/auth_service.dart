// Authentication service for managing user authentication
// Handles anonymous sign-in, user sessions, and guest user ID generation
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import '../exceptions/auth_exception.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<User?> signInAnonymously() async {
    try {
      // Check if a user is already signed in
      final currentUser = _supabaseClient.auth.currentUser;
      if (currentUser != null) {
        AppLogger.info('User already signed in: ${currentUser.id}');
        return currentUser;
      }

      // Check if we have an existing session
      final session = _supabaseClient.auth.currentSession;
      if (session?.user != null) {
        AppLogger.info('Using existing session: ${session!.user.id}');
        return session.user;
      }

      // Try anonymous sign-in if enabled
      AppLogger.info('Attempting anonymous sign-in');
      try {
        final response = await _supabaseClient.auth.signInAnonymously();

        if (response.user == null) {
          AppLogger.warning('No user returned after anonymous sign-in attempt');
          return _handleGuestMode();
        }

        AppLogger.info('Anonymous sign-in successful: ${response.user!.id}');
        return response.user;
      } on AuthException catch (authError) {
        AppLogger.warning('Anonymous auth failed: ${authError.message}');

        // Check if anonymous auth is not enabled (common 422 error)
        if (authError.message.contains('Anonymous') ||
            authError.message.contains('signup') ||
            authError.statusCode == '422') {
          AppLogger.info(
            'Anonymous authentication not enabled, switching to guest mode',
          );
          return _handleGuestMode();
        }

        rethrow;
      }
    } on AuthException catch (e) {
      AppLogger.error('Authentication error: ${e.message}', e);

      // For 422 errors, try guest mode
      if (e.statusCode == '422') {
        AppLogger.info('422 error detected, switching to guest mode');
        return _handleGuestMode();
      }

      throw AuthFailedException('Authentication failed: ${e.message}', e);
    } catch (e) {
      AppLogger.error('Unexpected error during authentication', e);

      // Try guest mode as fallback
      AppLogger.info('Attempting guest mode as fallback');
      try {
        return _handleGuestMode();
      } catch (guestError) {
        throw AuthFailedException('All authentication methods failed', e);
      }
    }
  }

  // Guest mode - create a pseudo-user for local storage without server auth
  Future<User?> _handleGuestMode() async {
    try {
      // Generate a local guest user ID based on device/session
      final guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      AppLogger.info('Entering guest mode with ID: $guestId');

      // Store guest ID locally for consistency
      // Note: We return null here because we don't have a real Supabase User object
      // The app will handle null user by using the guest ID for local operations
      return null;
    } catch (e) {
      AppLogger.error('Guest mode setup failed', e);
      return null;
    }
  }

  // Get guest user ID for local operations
  String getGuestUserId() {
    // Create a consistent guest ID for this session
    return 'guest_${DateTime.now().day}${DateTime.now().month}${DateTime.now().year}';
  }

  // Get current user
  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  // Sign out
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }
}
