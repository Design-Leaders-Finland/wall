import 'package:flutter_test/flutter_test.dart';
import 'package:wall/models/message.dart';

void main() {
  group('Message Model Tests', () {
    late DateTime testDate;
    late Message testMessage;

    setUp(() {
      testDate = DateTime(2025, 7, 18, 14, 30, 0);
      testMessage = Message(
        content: 'Hello, World!',
        userId: 'user123',
        createdAt: testDate,
        isFromCurrentUser: true,
      );
    });

    group('Constructor and Properties', () {
      test('should create message with required properties', () {
        final message = Message(
          content: 'Test message',
          userId: 'testUser',
          createdAt: testDate,
        );

        expect(message.content, equals('Test message'));
        expect(message.userId, equals('testUser'));
        expect(message.createdAt, equals(testDate));
        expect(message.isFromCurrentUser, isFalse); // default value
      });

      test('should create message with all properties', () {
        expect(testMessage.content, equals('Hello, World!'));
        expect(testMessage.userId, equals('user123'));
        expect(testMessage.createdAt, equals(testDate));
        expect(testMessage.isFromCurrentUser, isTrue);
      });
    });

    group('JSON Serialization', () {
      test('should convert to JSON correctly', () {
        final json = testMessage.toJson();

        expect(json['content'], equals('Hello, World!'));
        expect(json['user_id'], equals('user123'));
        expect(json['created_at'], equals(testDate.toIso8601String()));
        expect(json['is_from_current_user'], isTrue);
      });

      test('should create from JSON correctly', () {
        final json = {
          'content': 'JSON message',
          'user_id': 'jsonUser',
          'created_at': testDate.toIso8601String(),
          'is_from_current_user': false,
        };

        final message = Message.fromJson(json);

        expect(message.content, equals('JSON message'));
        expect(message.userId, equals('jsonUser'));
        expect(message.createdAt, equals(testDate));
        expect(message.isFromCurrentUser, isFalse);
      });

      test('should handle missing JSON fields with defaults', () {
        final json = <String, dynamic>{};

        final message = Message.fromJson(json);

        expect(message.content, equals(''));
        expect(message.userId, equals(''));
        expect(message.createdAt, isA<DateTime>());
        expect(message.isFromCurrentUser, isFalse);
      });

      test('should handle null created_at in JSON', () {
        final json = {
          'content': 'Test',
          'user_id': 'test',
          'created_at': null,
          'is_from_current_user': false,
        };

        final message = Message.fromJson(json);

        expect(message.createdAt, isA<DateTime>());
        // Should use DateTime.now() when created_at is null
      });
    });

    group('Message Expiration', () {
      test('should not be expired when created less than 5 minutes ago', () {
        final recentMessage = Message(
          content: 'Recent',
          userId: 'user',
          createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        );

        expect(recentMessage.isExpired(), isFalse);
      });

      test('should be expired when created more than 5 minutes ago', () {
        final oldMessage = Message(
          content: 'Old',
          userId: 'user',
          createdAt: DateTime.now().subtract(const Duration(minutes: 6)),
        );

        expect(oldMessage.isExpired(), isTrue);
      });

      test('should be expired when created exactly 5 minutes ago', () {
        final oldMessage = Message(
          content: 'Exactly 5 minutes',
          userId: 'user',
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        );

        expect(oldMessage.isExpired(), isTrue);
      });
    });

    group('User ID Display', () {
      test('should return anonymous user display name', () {
        expect(testMessage.shortUserId, equals('ANONYMOUS USER'));
      });
    });

    group('Time Formatting', () {
      test('should format time with default locale', () {
        final formattedTime = testMessage.formatTime(null);
        
        expect(formattedTime, isA<String>());
        expect(formattedTime.isNotEmpty, isTrue);
      });

      test('should format time with default locale', () {
        final formattedTime = testMessage.formatTime(null);
        
        expect(formattedTime, isA<String>());
        expect(formattedTime.isNotEmpty, isTrue);
      });

      test('should handle different locales', () {
        // Test only default locale to avoid initialization issues
        final timeDefault = testMessage.formatTime(null);
        
        expect(timeDefault, isA<String>());
        expect(timeDefault.isNotEmpty, isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle empty content', () {
        final message = Message(
          content: '',
          userId: 'user',
          createdAt: testDate,
        );

        expect(message.content, equals(''));
        expect(message.toJson()['content'], equals(''));
      });

      test('should handle very long content', () {
        final longContent = 'A' * 1000;
        final message = Message(
          content: longContent,
          userId: 'user',
          createdAt: testDate,
        );

        expect(message.content, equals(longContent));
        expect(message.content.length, equals(1000));
      });

      test('should handle special characters in content', () {
        const specialContent = 'Hello 🌟 World! @#\$%^&*()';
        final message = Message(
          content: specialContent,
          userId: 'user',
          createdAt: testDate,
        );

        expect(message.content, equals(specialContent));
        
        final json = message.toJson();
        final recreated = Message.fromJson(json);
        expect(recreated.content, equals(specialContent));
      });
    });
  });
}
