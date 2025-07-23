import 'package:flutter_test/flutter_test.dart';
import 'package:wall/controllers/connection_manager.dart';

void main() {
  group('ConnectionManager Tests', () {
    late ConnectionManager connectionManager;

    setUp(() {
      connectionManager = ConnectionManager();
    });

    group('Initial State', () {
      test('should start in online mode', () {
        // Assert
        expect(connectionManager.isOffline, isFalse);
        expect(connectionManager.localMessageCount, equals(0));
      });
    });

    group('Connection State Management', () {
      test('should update connection state correctly', () {
        // Act
        connectionManager.updateConnectionState(
          isOffline: true,
          localMessageCount: 5,
        );

        // Assert
        expect(connectionManager.isOffline, isTrue);
        expect(connectionManager.localMessageCount, equals(5));
      });

      test('should set offline mode with message count', () {
        // Act
        connectionManager.setOfflineMode(3);

        // Assert
        expect(connectionManager.isOffline, isTrue);
        expect(connectionManager.localMessageCount, equals(3));
      });

      test('should set online mode', () {
        // Arrange
        connectionManager.setOfflineMode(5);

        // Act
        connectionManager.setOnlineMode();

        // Assert
        expect(connectionManager.isOffline, isFalse);
        expect(connectionManager.localMessageCount, equals(0));
      });
    });

    group('Display Text', () {
      test('should return OFFLINE when no local messages', () {
        // Arrange
        connectionManager.setOfflineMode(0);

        // Act
        final displayText = connectionManager.getOfflineDisplayText();

        // Assert
        expect(displayText, equals('OFFLINE'));
      });

      test('should return OFFLINE with count when has local messages', () {
        // Arrange
        connectionManager.setOfflineMode(3);

        // Act
        final displayText = connectionManager.getOfflineDisplayText();

        // Assert
        expect(displayText, equals('OFFLINE (3)'));
      });
    });
  });
}
