import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:wall/models/message.dart';
import 'package:wall/widgets/message_list_item.dart';

void main() {
  group('MessageListItem Widget Tests', () {
    testWidgets('should display message content and timestamp', (tester) async {
      final message = Message(
        content: 'Test message content',
        createdAt: DateTime.now(),
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      expect(find.text('Test message content'), findsOneWidget);
      expect(find.text(message.shortUserId), findsOneWidget);
    });

    testWidgets('should show "YOU" for current user messages', (tester) async {
      final message = Message(
        content: 'My message',
        createdAt: DateTime.now(),
        userId: 'current-user',
        isFromCurrentUser: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      expect(find.text('YOU'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should show user ID for other user messages', (tester) async {
      final message = Message(
        content: 'Other user message',
        createdAt: DateTime.now(),
        userId: 'other-user-123',
        isFromCurrentUser: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      expect(find.text(message.shortUserId), findsOneWidget);
      expect(find.text('YOU'), findsNothing);
      expect(find.byIcon(Icons.person), findsNothing);
    });

    testWidgets('should display formatted timestamp', (tester) async {
      // Initialize date formatting for tests
      await initializeDateFormatting('en', null);

      final testTime = DateTime(2025, 1, 25, 14, 30);
      final message = Message(
        content: 'Test message',
        createdAt: testTime,
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      final formattedTime = message.formatTime('en');
      expect(find.text(formattedTime), findsOneWidget);
    });

    testWidgets('should apply correct styling for current user', (
      tester,
    ) async {
      final message = Message(
        content: 'My message',
        createdAt: DateTime.now(),
        userId: 'current-user',
        isFromCurrentUser: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      // Check if the container has background color for current user
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MessageListItem),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.color, isNotNull);
      expect(container.color, isNot(Colors.transparent));
    });

    testWidgets('should apply transparent background for other users', (
      tester,
    ) async {
      final message = Message(
        content: 'Other message',
        createdAt: DateTime.now(),
        userId: 'other-user',
        isFromCurrentUser: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MessageListItem),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.color, Colors.transparent);
    });

    testWidgets('should display divider at bottom', (tester) async {
      final message = Message(
        content: 'Test message',
        createdAt: DateTime.now(),
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      expect(find.byType(Divider), findsOneWidget);
    });

    testWidgets('should handle very long content', (tester) async {
      final longContent = 'A' * 200; // Very long message
      final message = Message(
        content: longContent,
        createdAt: DateTime.now(),
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      expect(find.text(longContent), findsOneWidget);
    });

    testWidgets('should handle special characters in content', (tester) async {
      const specialContent = 'Test with émojis 🚀 and spëcial chars!';
      final message = Message(
        content: specialContent,
        createdAt: DateTime.now(),
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      expect(find.text(specialContent), findsOneWidget);
    });

    testWidgets('should use proper layout structure', (tester) async {
      final message = Message(
        content: 'Test layout',
        createdAt: DateTime.now(),
        userId: 'user123',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: MessageListItem(message: message)),
        ),
      );

      // Check overall structure
      expect(find.byType(Column), findsWidgets);
      expect(
        find.byType(Container),
        findsAtLeastNWidgets(1),
      ); // Divider creates additional containers
      expect(find.byType(Row), findsAtLeastNWidgets(1));
      expect(
        find.byType(SizedBox),
        findsAtLeastNWidgets(1),
      ); // Multiple SizedBox widgets may exist
      expect(find.byType(Divider), findsOneWidget);
    });
  });
}
