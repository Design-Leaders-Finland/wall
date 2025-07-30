import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/widgets/message_input.dart';

void main() {
  group('MessageInput Cooldown Tests', () {
    testWidgets('Send button is disabled when in cooldown', (
      WidgetTester tester,
    ) async {
      bool sendCalled = false;

      // Create a MessageInput with cooldown enabled
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageInput(
              onSendMessage: (message) async {
                sendCalled = true;
                return true;
              },
              isInCooldown: true,
            ),
          ),
        ),
      );

      // Find the send button by looking for IconButton with send icon
      final sendButton = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.icon is Icon &&
            (widget.icon as Icon).icon == Icons.send_rounded,
      );
      expect(sendButton, findsOneWidget);

      // Verify the button is disabled
      final IconButton button = tester.widget(sendButton);
      expect(button.onPressed, isNull);

      // Try to tap the button (should not work since it's disabled)
      await tester.tap(sendButton);
      await tester.pump();

      // Verify onSendMessage was not called
      expect(sendCalled, false);
    });

    testWidgets('Send button is enabled when not in cooldown', (
      WidgetTester tester,
    ) async {
      bool sendCalled = false;

      // Create a MessageInput without cooldown
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageInput(
              onSendMessage: (message) async {
                sendCalled = true;
                return true;
              },
              isInCooldown: false,
            ),
          ),
        ),
      );

      // Enter some text
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.pump();

      // Find the send button by looking for IconButton with send icon
      final sendButton = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.icon is Icon &&
            (widget.icon as Icon).icon == Icons.send_rounded,
      );
      expect(sendButton, findsOneWidget);

      // Verify the button is enabled
      final IconButton button = tester.widget(sendButton);
      expect(button.onPressed, isNotNull);

      // Tap the button
      await tester.tap(sendButton);
      await tester.pump();

      // Verify onSendMessage was called
      expect(sendCalled, true);
    });

    testWidgets('Text is preserved when send fails', (
      WidgetTester tester,
    ) async {
      // Create a MessageInput that simulates failed send
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageInput(
              onSendMessage: (message) async {
                return false; // Simulate failed send
              },
              isInCooldown: false,
            ),
          ),
        ),
      );

      const testMessage = 'Test message';

      // Enter some text
      await tester.enterText(find.byType(TextField), testMessage);
      await tester.pump();

      // Tap the send button
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              widget.icon is Icon &&
              (widget.icon as Icon).icon == Icons.send_rounded,
        ),
      );
      await tester.pumpAndSettle(); // Wait for async operation

      // Verify text is still there
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('Text is cleared when send succeeds', (
      WidgetTester tester,
    ) async {
      // Create a MessageInput that simulates successful send
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageInput(
              onSendMessage: (message) async {
                return true; // Simulate successful send
              },
              isInCooldown: false,
            ),
          ),
        ),
      );

      const testMessage = 'Test message';

      // Enter some text
      await tester.enterText(find.byType(TextField), testMessage);
      await tester.pump();

      // Tap the send button
      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is IconButton &&
              widget.icon is Icon &&
              (widget.icon as Icon).icon == Icons.send_rounded,
        ),
      );
      await tester.pumpAndSettle(); // Wait for async operation

      // Verify text is cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('Tooltip shows cooldown message when in cooldown', (
      WidgetTester tester,
    ) async {
      // Create a MessageInput with cooldown
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageInput(
              onSendMessage: (message) async => true,
              isInCooldown: true,
            ),
          ),
        ),
      );

      // Find the send button by looking for IconButton with send icon
      final sendButton = find.byWidgetPredicate(
        (widget) =>
            widget is IconButton &&
            widget.icon is Icon &&
            (widget.icon as Icon).icon == Icons.send_rounded,
      );

      // Long press to show tooltip
      await tester.longPress(sendButton);
      await tester.pumpAndSettle();

      // Verify cooldown tooltip is shown
      expect(find.text('Wait for cooldown to finish'), findsOneWidget);
    });
  });
}
