import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class AppInitializationService {
  // Minimum duration for splash screen in milliseconds
  static const int minimumSplashDuration = 500;
  
  // Initialize the app and ensure minimum splash duration
  static Future<void> initializeApp() async {
    AppLogger.info('Starting app initialization');
    
    // Record start time to calculate elapsed time later
    final startTime = DateTime.now();
    
    try {
      // Initialize Supabase client
      await Supabase.initialize(
        url: 'https://vncfwjhduqhevwjspnny.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZuY2Z3amhkdXFoZXZ3anNwbm55Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTIyMzE0NDksImV4cCI6MjA2NzgwNzQ0OX0.3ATScVIraTIukGP0bchZrWOZEYmzRb0wO2GcqzqHt_A',
      );
      
      // Calculate elapsed time
      final elapsedMilliseconds = DateTime.now().difference(startTime).inMilliseconds;
      AppLogger.info('Initialization completed in $elapsedMilliseconds ms');
      
      // If initialization was faster than minimum splash duration, 
      // wait for the remaining time
      if (elapsedMilliseconds < minimumSplashDuration) {
        final remainingTime = minimumSplashDuration - elapsedMilliseconds;
        AppLogger.info('Waiting additional $remainingTime ms to meet minimum splash duration');
        await Future.delayed(Duration(milliseconds: remainingTime));
      }
      
    } catch (e, stackTrace) {
      AppLogger.error('Error during app initialization', e, stackTrace);
      // Still ensure minimum splash duration even if there was an error
      final elapsedMilliseconds = DateTime.now().difference(startTime).inMilliseconds;
      if (elapsedMilliseconds < minimumSplashDuration) {
        await Future.delayed(
          Duration(milliseconds: minimumSplashDuration - elapsedMilliseconds)
        );
      }
      rethrow; // Re-throw the error so it can be handled in the UI
    }
  }
}
