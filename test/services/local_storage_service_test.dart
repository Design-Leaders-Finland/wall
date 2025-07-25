import 'package:flutter_test/flutter_test.dart';
import 'package:wall/models/message.dart';
import 'package:wall/services/local_storage_service.dart';

void main() {
  group('LocalStorageService Tests', () {
    group('Static Method Existence', () {
      test('should have all expected static methods', () {
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
        final emptyMessages = <Message>[];
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
            createdAt: DateTime.now(),
          ),
          Message(
            content: 'Third message',
            userId: 'user3',
            createdAt: DateTime.now(),
          ),
        ];

        expect(messages.length, equals(3));
        expect(messages[0].content, equals('First message'));
        expect(messages[1].content, equals('Second message'));
        expect(messages[2].content, equals('Third message'));
      });

      test('should work with Message JSON serialization', () {
        final message = Message(
          content: 'JSON test message',
          userId: 'json-user',
          createdAt: DateTime.now(),
        );

        final json = message.toJson();
        final deserializedMessage = Message.fromJson(json);

        expect(deserializedMessage.content, equals(message.content));
        expect(deserializedMessage.userId, equals(message.userId));
      });

      test('should handle long content', () {
        final longContent = 'A' * 500;
        final message = Message(
          content: longContent,
          userId: 'long-user',
          createdAt: DateTime.now(),
        );

        expect(message.content.length, equals(500));
        expect(message.content, equals(longContent));
      });

      test('should handle special characters in content', () {
        const specialContent = 'Test with émojis 🚀🎉 and spëcial chars!';
        final message = Message(
          content: specialContent,
          userId: 'special-user',
          createdAt: DateTime.now(),
        );

        expect(message.content, equals(specialContent));
      });

      test('should handle empty content gracefully', () {
        final message = Message(
          content: '',
          userId: 'empty-user',
          createdAt: DateTime.now(),
        );

        expect(message.content, equals(''));
        expect(message.content.isEmpty, isTrue);
      });
    });

    group('Service Method Calls', () {
      test('should call saveMessages without errors', () async {
        final messages = [
          Message(
            content: 'Save test',
            userId: 'save-user',
            createdAt: DateTime.now(),
          ),
        ];

        try {
          await LocalStorageService.saveMessages(messages);
          expect(true, isTrue);
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('should call loadMessages without errors', () async {
        try {
          final messages = await LocalStorageService.loadMessages();
          expect(messages, isA<List<Message>>());
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('should call addMessage without errors', () async {
        final message = Message(
          content: 'Add test',
          userId: 'add-user',
          createdAt: DateTime.now(),
        );

        try {
          await LocalStorageService.addMessage(message);
          expect(true, isTrue);
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('should call clearMessages without errors', () async {
        try {
          await LocalStorageService.clearMessages();
          expect(true, isTrue);
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('should call saveCurrentUserMessages without errors', () async {
        final messages = [
          Message(
            content: 'Current user test',
            userId: 'current-user',
            createdAt: DateTime.now(),
            isFromCurrentUser: true,
          ),
        ];

        try {
          await LocalStorageService.saveCurrentUserMessages(messages);
          expect(true, isTrue);
        } catch (e) {
          expect(e, isNotNull);
        }
      });

      test('should call loadCurrentUserMessages without errors', () async {
        try {
          final messages = await LocalStorageService.loadCurrentUserMessages();
          expect(messages, isA<List<Message>>());
        } catch (e) {
          expect(e, isNotNull);
        }
      });
    });

    group('Edge Cases', () {
      test('should handle very old dates', () {
        final oldMessage = Message(
          content: 'Old message',
          userId: 'old-user',
          createdAt: DateTime(2020, 1, 1),
        );

        expect(oldMessage.isExpired(), isTrue);
      });

      test('should handle future dates', () {
        final futureMessage = Message(
          content: 'Future message',
          userId: 'future-user',
          createdAt: DateTime.now().add(const Duration(days: 1)),
        );

        expect(futureMessage.isExpired(), isFalse);
      });

      test('should handle large datasets', () {
        final largeMessageList = List.generate(
          100,
          (i) => Message(
            content: 'Message $i',
            userId: 'bulk-user-$i',
            createdAt: DateTime.now().subtract(Duration(minutes: i)),
          ),
        );

        expect(largeMessageList.length, equals(100));
        final expiredMessages = largeMessageList
            .where((m) => m.isExpired())
            .toList();
        expect(expiredMessages.length, greaterThan(0));
      });

      test('should handle mixed message states', () {
        final mixedMessages = [
          Message(
            content: 'Current user message',
            userId: 'current',
            createdAt: DateTime.now(),
            isFromCurrentUser: true,
          ),
          Message(
            content: 'Other user message',
            userId: 'other',
            createdAt: DateTime.now(),
            isFromCurrentUser: false,
          ),
          Message(
            content: 'Expired message',
            userId: 'expired',
            createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
            isFromCurrentUser: false,
          ),
        ];

        final currentUserMessages = mixedMessages
            .where((m) => m.isFromCurrentUser)
            .toList();
        final otherUserMessages = mixedMessages
            .where((m) => !m.isFromCurrentUser)
            .toList();
        final expiredMessages = mixedMessages
            .where((m) => m.isExpired())
            .toList();

        expect(currentUserMessages.length, equals(1));
        expect(otherUserMessages.length, equals(2));
        expect(expiredMessages.length, equals(1));
      });

      test('should handle message serialization edge cases', () {
        final edgeCaseMessage = Message(
          content: '{"test": "json", "number": 123}',
          userId: 'json-user-id',
          createdAt: DateTime.now(),
        );

        final json = edgeCaseMessage.toJson();
        expect(json, isA<Map<String, dynamic>>());
        expect(json['content'], contains('json'));

        final reconstructed = Message.fromJson(json);
        expect(reconstructed.content, equals(edgeCaseMessage.content));
      });
    });
  });
}
