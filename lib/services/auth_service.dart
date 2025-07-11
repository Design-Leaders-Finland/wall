import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  // Sign in anonymously
  Future<User?> signInAnonymously() async {
    try {
      final response = await _supabaseClient.auth.signInAnonymously();
      return response.user;
    } on AuthException catch (e) {
      AppLogger.error('Oops, error signing in: ${e.message}', e);
      return null;
    } catch (e) {
      AppLogger.error('Something unexpected happened during authentication', e);
      return null;
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
