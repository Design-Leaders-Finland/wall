import 'package:flutter_test/flutter_test.dart';
import 'package:wall/services/message_service.dart';

void main() {
  group('MessageService.sanitizeInput', () {
    test('trims whitespace from both ends', () {
      expect(MessageService.sanitizeInput('   hello   '), 'hello');
    });

    test('removes control characters', () {
      expect(MessageService.sanitizeInput('hi\x00\x1Fthere'), 'hithere');
    });

    test('removes invisible Unicode', () {
      expect(
        MessageService.sanitizeInput('a\u200B\u200F\u202A\u202E b'),
        'a b',
      );
    });

    test('collapses multiple spaces', () {
      expect(MessageService.sanitizeInput('a    b   c'), 'a b c');
    });

    test('handles only whitespace', () {
      expect(MessageService.sanitizeInput('     '), '');
    });

    test('handles empty string', () {
      expect(MessageService.sanitizeInput(''), '');
    });

    test('does not modify normal text', () {
      expect(MessageService.sanitizeInput('Hello world!'), 'Hello world!');
    });

    test('removes mixed unwanted chars', () {
      expect(
        MessageService.sanitizeInput('  \x00\u200Bfoo   bar\x1F\u202E  '),
        'foo bar',
      );
    });
  });
}
