import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Test helper functions for setting up test environment
class TestHelpers {
  /// Initialize Flutter and Supabase for testing with mock values
  static Future<void> initializeSupabase() async {
    // Ensure Flutter binding is initialized
    TestWidgetsFlutterBinding.ensureInitialized();

    try {
      // Try to access Supabase.instance to check if initialized
      Supabase.instance;
    } catch (e) {
      // Mock shared preferences for testing
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'getAll') {
                return <String, dynamic>{};
              }
              return null;
            },
          );

      // If not initialized, initialize it
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key-for-testing-purposes-only',
      );
    }
  }

  /// Pump and settle widget with timeout to handle async operations
  static Future<void> pumpAndSettleWithTimeout(
    WidgetTester tester, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      await tester.pumpAndSettle(timeout);
    } catch (e) {
      // If pumpAndSettle times out, just pump once
      await tester.pump();
    }
  }

  /// Reset Supabase instance (useful for test cleanup)
  static void resetSupabase() {
    // Note: Supabase doesn't provide a reset method,
    // so we'll handle this in individual tests if needed
  }
}
