import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:wall/utils/logger.dart';

void main() {
  group('AppLogger Tests', () {
    late List<LogRecord> capturedLogs;

    setUp(() {
      capturedLogs = [];
      // Set up a test listener to capture log records
      Logger.root.clearListeners();
      Logger.root.onRecord.listen((record) {
        capturedLogs.add(record);
      });
      Logger.root.level = Level.ALL;
    });

    tearDown(() {
      Logger.root.clearListeners();
      capturedLogs.clear();
    });

    group('Logger Setup', () {
      test('should setup logger correctly', () {
        AppLogger.setup();

        // Verify that the logger root level is set to ALL
        expect(Logger.root.level, equals(Level.ALL));

        // Test that setup doesn't throw an exception
        expect(() => AppLogger.setup(), returnsNormally);
      });
    });

    group('Info Logging', () {
      test('should log info messages', () {
        AppLogger.info('Test info message');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.INFO));
        expect(capturedLogs.first.message, equals('Test info message'));
        expect(capturedLogs.first.loggerName, equals('WallApp'));
      });

      test('should log multiple info messages', () {
        AppLogger.info('First message');
        AppLogger.info('Second message');

        expect(capturedLogs, hasLength(2));
        expect(capturedLogs[0].message, equals('First message'));
        expect(capturedLogs[1].message, equals('Second message'));
        expect(capturedLogs.every((log) => log.level == Level.INFO), isTrue);
      });

      test('should handle empty info messages', () {
        AppLogger.info('');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(''));
        expect(capturedLogs.first.level, equals(Level.INFO));
      });
    });

    group('Warning Logging', () {
      test('should log warning messages', () {
        AppLogger.warning('Test warning message');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.WARNING));
        expect(capturedLogs.first.message, equals('Test warning message'));
        expect(capturedLogs.first.loggerName, equals('WallApp'));
      });

      test('should differentiate between info and warning levels', () {
        AppLogger.info('Info message');
        AppLogger.warning('Warning message');

        expect(capturedLogs, hasLength(2));
        expect(capturedLogs[0].level, equals(Level.INFO));
        expect(capturedLogs[1].level, equals(Level.WARNING));
      });
    });

    group('Error Logging', () {
      test('should log error messages without error object', () {
        AppLogger.error('Test error message');

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.SEVERE));
        expect(capturedLogs.first.message, equals('Test error message'));
        expect(capturedLogs.first.error, isNull);
        expect(capturedLogs.first.stackTrace, isNull);
      });

      test('should log error messages with error object', () {
        final error = Exception('Test exception');
        AppLogger.error('Test error message', error);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.SEVERE));
        expect(capturedLogs.first.message, equals('Test error message'));
        expect(capturedLogs.first.error, equals(error));
        expect(capturedLogs.first.stackTrace, isNull);
      });

      test('should log error messages with error and stack trace', () {
        final error = Exception('Test exception');
        final stackTrace = StackTrace.current;

        AppLogger.error('Test error message', error, stackTrace);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.level, equals(Level.SEVERE));
        expect(capturedLogs.first.message, equals('Test error message'));
        expect(capturedLogs.first.error, equals(error));
        expect(capturedLogs.first.stackTrace, equals(stackTrace));
      });
    });

    group('Mixed Logging Levels', () {
      test('should maintain correct order of mixed log levels', () {
        AppLogger.info('Info 1');
        AppLogger.warning('Warning 1');
        AppLogger.error('Error 1');
        AppLogger.info('Info 2');

        expect(capturedLogs, hasLength(4));
        expect(capturedLogs[0].level, equals(Level.INFO));
        expect(capturedLogs[0].message, equals('Info 1'));
        expect(capturedLogs[1].level, equals(Level.WARNING));
        expect(capturedLogs[1].message, equals('Warning 1'));
        expect(capturedLogs[2].level, equals(Level.SEVERE));
        expect(capturedLogs[2].message, equals('Error 1'));
        expect(capturedLogs[3].level, equals(Level.INFO));
        expect(capturedLogs[3].message, equals('Info 2'));
      });
    });

    group('Special Characters and Unicode', () {
      test('should handle special characters in log messages', () {
        const message = 'Special chars: @#\$%^&*() 🌟 émojis';
        AppLogger.info(message);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(message));
      });

      test('should handle unicode in log messages', () {
        const message = 'Unicode: 你好 世界 🌍 Ñoño';
        AppLogger.warning(message);

        expect(capturedLogs, hasLength(1));
        expect(capturedLogs.first.message, equals(message));
      });
    });

    group('Logger Name Consistency', () {
      test('should use consistent logger name across all log levels', () {
        AppLogger.info('Info');
        AppLogger.warning('Warning');
        AppLogger.error('Error');

        expect(capturedLogs, hasLength(3));
        expect(
          capturedLogs.every((log) => log.loggerName == 'WallApp'),
          isTrue,
        );
      });
    });

    group('Performance Tests', () {
      test('should handle multiple rapid log calls', () {
        for (int i = 0; i < 100; i++) {
          AppLogger.info('Message $i');
        }

        expect(capturedLogs, hasLength(100));
        expect(capturedLogs.first.message, equals('Message 0'));
        expect(capturedLogs.last.message, equals('Message 99'));
      });
    });
  });
}
