import 'package:flutter_test/flutter_test.dart';
import 'package:wall/controllers/auth_controller.dart';
import 'package:wall/exceptions/auth_exception.dart';

void main() {
  group('AuthController Tests', () {
    late AuthController authController;

    setUp(() {
      authController = AuthController();
    });

    group('getUserIdForMessaging', () {
      test('should return guest ID when no authenticated user', () {
        // Act
        final (userId, isGuest) = authController.getUserIdForMessaging();

        // Assert
        expect(isGuest, isTrue);
        expect(userId, isNotEmpty);
        expect(userId.startsWith('guest_'), isTrue);
      });

      test('should generate consistent guest IDs within same day', () {
        // Act
        final (userId1, isGuest1) = authController.getUserIdForMessaging();
        final (userId2, isGuest2) = authController.getUserIdForMessaging();

        // Assert
        expect(isGuest1, isTrue);
        expect(isGuest2, isTrue);
        expect(userId1, equals(userId2));
      });
    });

    group('getGuestUserId', () {
      test('should generate guest user ID', () {
        // Act
        final guestId = authController.getGuestUserId();

        // Assert
        expect(guestId, isNotEmpty);
        expect(guestId.startsWith('guest_'), isTrue);
      });

      test('should generate same ID for same day', () {
        // Act
        final guestId1 = authController.getGuestUserId();
        final guestId2 = authController.getGuestUserId();

        // Assert
        expect(guestId1, equals(guestId2));
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
