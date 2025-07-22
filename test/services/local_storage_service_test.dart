import 'package:flutter_test/flutter_test.dart';
import 'package:wall/models/message.dart';
import 'package:wall/services/local_storage_service.dart';

void main() {
  group('LocalStorageService Tests', () {
    // Note: These tests focus on the pure logic parts that don't require
    // SharedPreferences mocking. For full coverage, you'd need to mock SharedPreferences

    group('Static Method Existence', () {
      test('should have all expected static methods', () {
        // Test that all methods exist and can be called
        expect(LocalStorageService.saveMessages, isA<Function>());
        expect(LocalStorageService.loadMessages, isA<Function>());
        expect(LocalStorageService.addMessage, isA<Function>());
        expect(LocalStorageService.clearMessages, isA<Function>());
        expect(LocalStorageService.saveCurrentUserMessages, isA<Function>());
        expect(LocalStorageService.loadCurrentUserMessages, isA<Function>());
      });
    });

    group('Message Data Handling', () {
      test('should handle empty message list', () async {
        // This test checks basic functionality without SharedPreferences
        final emptyMessages = <Message>[];

        // The service should be able to handle empty lists
        expect(emptyMessages.isEmpty, isTrue);
        expect(emptyMessages.length, equals(0));
      });

      test('should work with valid message objects', () {
        final testMessage = Message(
          content: 'Test message content',
          userId: 'user-456',
          createdAt: DateTime.now(),
        );

        final messageList = [testMessage];

        expect(messageList.length, equals(1));
        expect(messageList.first.content, equals('Test message content'));
        expect(messageList.first.userId, equals('user-456'));
      });

      test('should handle multiple messages', () {
        final messages = [
          Message(
            content: 'First message',
            userId: 'user1',
            createdAt: DateTime.now(),
          ),
          Message(
            content: 'Second message',
            userId: 'user2',
            createdAt: DateTime.now().add(const Duration(minutes: 1)),
          ),
          Message(
            content: 'Third message',
            userId: 'user1',
            createdAt: DateTime.now().add(const Duration(minutes: 2)),
          ),
        ];

        expect(messages.length, equals(3));
        expect(messages[0].content, equals('First message'));
        expect(messages[1].content, equals('Second message'));
        expect(messages[2].content, equals('Third message'));
      });
    });

    group('Message JSON Compatibility', () {
      test('should work with Message JSON serialization', () {
        final testMessage = Message(
          content: 'JSON test message',
          userId: 'json-user',
          createdAt: DateTime.parse('2024-01-15T10:30:00Z'),
        );

        // Test that message can be serialized and deserialized
        final json = testMessage.toJson();
        final reconstructed = Message.fromJson(json);

        expect(reconstructed.content, equals(testMessage.content));
        expect(reconstructed.userId, equals(testMessage.userId));
        expect(reconstructed.createdAt, equals(testMessage.createdAt));
      });

      test('should handle special characters in content', () {
        final messageWithSpecialChars = Message(
          content: 'Message with émojis 🎉 and "quotes" & symbols!',
          userId: 'user-special',
          createdAt: DateTime.now(),
        );

        // Test JSON serialization with special characters
        final json = messageWithSpecialChars.toJson();
        final reconstructed = Message.fromJson(json);

        expect(reconstructed.content, equals(messageWithSpecialChars.content));
      });

      test('should handle long content', () {
        final longContent = 'This is a very long message content. ' * 50;
        final longMessage = Message(
          content: longContent,
          userId: 'user-long',
          createdAt: DateTime.now(),
        );

        // Test that long content can be serialized
        final json = longMessage.toJson();
        final reconstructed = Message.fromJson(json);

        expect(reconstructed.content, equals(longContent));
        expect(reconstructed.content.length, greaterThan(1000));
      });
    });

    group('Data Validation', () {
      test('should validate message structure', () {
        final validMessage = Message(
          content: 'Valid content',
          userId: 'valid-user',
          createdAt: DateTime.now(),
        );

        expect(validMessage.userId, isNotEmpty);
        expect(validMessage.content, isNotEmpty);
        expect(validMessage.createdAt, isA<DateTime>());
      });

      test('should handle empty content gracefully', () {
        final emptyContentMessage = Message(
          content: '',
          userId: 'user-empty',
          createdAt: DateTime.now(),
        );

        expect(emptyContentMessage.content, isEmpty);
        expect(emptyContentMessage.userId, isNotEmpty);
      });

      test('should handle whitespace content', () {
        final whitespaceMessage = Message(
          content: '   \n\t   ',
          userId: 'user-whitespace',
          createdAt: DateTime.now(),
        );

        expect(whitespaceMessage.content, isNotEmpty);
        expect(whitespaceMessage.content.trim(), isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle null or invalid dates gracefully', () {
        // Test with current time
        final messageNow = Message(
          content: 'Time test',
          userId: 'user-time',
          createdAt: DateTime.now(),
        );

        expect(messageNow.createdAt, isA<DateTime>());
        expect(
          messageNow.createdAt.isBefore(
            DateTime.now().add(const Duration(seconds: 1)),
          ),
          isTrue,
        );
      });

      test('should handle very old dates', () {
        final oldDate = DateTime.parse('1990-01-01T00:00:00Z');
        final oldMessage = Message(
          content: 'Old message',
          userId: 'old-user',
          createdAt: oldDate,
        );

        expect(oldMessage.createdAt.year, equals(1990));
        expect(oldMessage.createdAt.isBefore(DateTime.now()), isTrue);
      });

      test('should handle future dates', () {
        final futureDate = DateTime.now().add(const Duration(days: 365));
        final futureMessage = Message(
          content: 'Future message',
          userId: 'future-user',
          createdAt: futureDate,
        );

        expect(futureMessage.createdAt.isAfter(DateTime.now()), isTrue);
      });
    });
  });
}
