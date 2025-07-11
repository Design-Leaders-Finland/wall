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

      // Try anonymous sign-in
      AppLogger.info('Attempting anonymous sign-in');
      final response = await _supabaseClient.auth.signInAnonymously();
      
      if (response.user == null) {
        throw AuthFailedException('No user returned after anonymous sign-in');
      }
      
      AppLogger.info('Anonymous sign-in successful: ${response.user!.id}');
      return response.user;
    } on AuthException catch (e) {
      AppLogger.error('Authentication error: ${e.message}', e);
      
      // Special handling for specific error codes
      if (e.message.contains('Email') || e.message.contains('signup')) {
        // Attempt to use a different auth approach if anonymous auth fails
        return _handleAuthFallback();
      }
      
      throw AuthFailedException('Authentication failed: ${e.message}', e);
    } catch (e) {
      AppLogger.error('Unexpected error during authentication', e);
      throw AuthFailedException('Unexpected error during authentication', e);
    }
  }
  
  // Fallback authentication method when anonymous auth fails
  Future<User?> _handleAuthFallback() async {
    try {
      // Try to use the session if it exists
      final session = _supabaseClient.auth.currentSession;
      if (session != null) {
        AppLogger.info('Using existing session');
        return _supabaseClient.auth.currentUser;
      }
      
      // Otherwise use guest access (without auth)
      AppLogger.info('Using guest access (no auth)');
      return null; // Return null but don't throw an exception
    } catch (e) {
      AppLogger.error('Fallback authentication failed', e);
      throw AuthFailedException('Fallback authentication failed', e);
    }
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
