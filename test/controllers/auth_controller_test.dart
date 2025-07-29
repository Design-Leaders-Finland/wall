import 'package:flutter_test/flutter_test.dart';
import 'package:wall/controllers/auth_controller.dart';
import 'package:wall/exceptions/auth_exception.dart';
import '../test_helpers.dart';

void main() {
  group('AuthController Tests', () {
    late AuthController authController;

    setUpAll(() async {
      await TestHelpers.initializeSupabase();
    });

    setUp(() {
      authController = AuthController();
    });

    group('getUserIdForMessaging', () {
      test('should return session UUID when no authenticated user', () {
        // Act
        final (userId, isGuest) = authController.getUserIdForMessaging();

        // Assert
        expect(isGuest, isTrue);
        expect(userId, isNotEmpty);
        // Should return a UUID format (not guest_ format) for database compatibility
        expect(userId.contains('-'), isTrue); // UUIDs contain hyphens
        expect(userId.length, equals(36)); // Standard UUID length
        expect(
          userId.startsWith('guest_'),
          isFalse,
        ); // No longer returns guest_ format
      });

      test('should generate consistent session UUIDs within same session', () {
        // Act
        final (userId1, isGuest1) = authController.getUserIdForMessaging();
        final (userId2, isGuest2) = authController.getUserIdForMessaging();

        // Assert
        expect(isGuest1, isTrue);
        expect(isGuest2, isTrue);
        // Session UUIDs should be consistent within the same session
        expect(userId1, equals(userId2));
      });
    });

    group('currentUser', () {
      test('should return null when not authenticated', () {
        // Act
        final user = authController.currentUser;

        // Assert
        expect(user, isNull);
      });
    });

    group('signInAnonymously', () {
      test('should handle authentication failure gracefully', () async {
        // This test assumes the auth service will fail in test environment
        // Act & Assert
        expect(
          () => authController.signInAnonymously(),
          throwsA(isA<AuthFailedException>()),
        );
      });
    });
  });
}
