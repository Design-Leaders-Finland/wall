import 'package:flutter_test/flutter_test.dart';
import 'package:wall/exceptions/auth_exception.dart';

void main() {
  group('AuthFailedException Tests', () {
    test('should create exception with message only', () {
      const message = 'Authentication failed';
      final exception = AuthFailedException(message);

      expect(exception.message, equals(message));
      expect(exception.originalError, isNull);
      expect(exception.toString(), equals(message));
    });

    test('should create exception with message and original error', () {
      const message = 'Authentication failed';
      final originalError = Exception('Network error');
      final exception = AuthFailedException(message, originalError);

      expect(exception.message, equals(message));
      expect(exception.originalError, equals(originalError));
      expect(exception.toString(), equals(message));
    });

    test('should implement Exception interface', () {
      final exception = AuthFailedException('Test message');
      expect(exception, isA<Exception>());
    });

    test('should handle empty message', () {
      const message = '';
      final exception = AuthFailedException(message);

      expect(exception.message, equals(message));
      expect(exception.toString(), equals(message));
    });

    test('should handle different types of original errors', () {
      const message = 'Auth failed';

      // Test with different error types
      final stringError = 'String error';
      final exception1 = AuthFailedException(message, stringError);
      expect(exception1.originalError, equals(stringError));

      final intError = 404;
      final exception2 = AuthFailedException(message, intError);
      expect(exception2.originalError, equals(intError));

      final mapError = {'code': 'invalid_credentials'};
      final exception3 = AuthFailedException(message, mapError);
      expect(exception3.originalError, equals(mapError));
    });
  });
}
