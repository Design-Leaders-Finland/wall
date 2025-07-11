import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';
import '../exceptions/auth_exception.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<User?> signInAnonymously() async {
    try {
      final response = await _supabaseClient.auth.signInAnonymously();
      if (response.user == null) {
        throw AuthFailedException('No user returned after anonymous sign-in');
      }
      return response.user;
    } on AuthException catch (e) {
      AppLogger.error('Authentication error: ${e.message}', e);
      throw AuthFailedException('Authentication failed: ${e.message}', e);
    } catch (e) {
      AppLogger.error('Unexpected error during authentication', e);
      throw AuthFailedException('Unexpected error during authentication', e);
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
