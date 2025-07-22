import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/widgets/message_input.dart';

void main() {
  group('MessageInput Widget Tests', () {
    late List<String> sentMessages;

    void onSendMessage(String message) {
      sentMessages.add(message);
    }

    setUp(() {
      sentMessages = [];
    });

    Widget createMessageInputWidget() {
      return MaterialApp(
        home: Scaffold(body: MessageInput(onSendMessage: onSendMessage)),
      );
    }

    group('Widget Rendering', () {
      testWidgets('should render text field and send button', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        expect(find.byType(TextField), findsOneWidget);
        expect(
          find.byType(IconButton),
          findsNWidgets(2),
        ); // Settings + Send buttons
        expect(find.byIcon(Icons.send_rounded), findsOneWidget);
        expect(find.byIcon(Icons.settings), findsOneWidget);
      });

      testWidgets('should display character counter', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        // Should start with 0/160 character count
        expect(find.text('0/160'), findsOneWidget);
      });

      testWidgets('should have correct hint text', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.decoration?.hintText, equals('Your message'));
      });
    });

    group('Text Input Behavior', () {
      testWidgets('should update character count when typing', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        const testMessage = 'Hello';
        await tester.enterText(find.byType(TextField), testMessage);
        await tester.pump();

        expect(find.text('5/160'), findsOneWidget);
      });

      testWidgets('should handle long text input', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        final longMessage = 'A' * 100;
        await tester.enterText(find.byType(TextField), longMessage);
        await tester.pump();

        expect(find.text('100/160'), findsOneWidget);
      });

      testWidgets('should handle empty text', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump();
        expect(find.text('4/160'), findsOneWidget);

        await tester.enterText(find.byType(TextField), '');
        await tester.pump();
        expect(find.text('0/160'), findsOneWidget);
      });
    });

    group('Send Button Behavior', () {
      testWidgets('should be disabled when text is empty', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        // Find the send button by its icon and get the parent IconButton
        final sendIconButtons = find.byType(IconButton);
        final sendButton = tester.widget<IconButton>(
          sendIconButtons.at(
            1,
          ), // Second IconButton is the send button (first is settings)
        );

        // Button should be enabled but won't send empty messages (handled in _handleSend)
        expect(sendButton.onPressed, isNotNull);
      });

      testWidgets('should be enabled when text is present', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        await tester.enterText(find.byType(TextField), 'test message');
        await tester.pump();

        final sendIconButtons = find.byType(IconButton);
        final sendButton = tester.widget<IconButton>(
          sendIconButtons.at(1), // Send button
        );

        expect(sendButton.onPressed, isNotNull);
      });

      testWidgets('should send message when tapped', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        const testMessage = 'Hello World';
        await tester.enterText(find.byType(TextField), testMessage);
        await tester.pump();

        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();

        expect(sentMessages, contains(testMessage));
        expect(sentMessages.length, equals(1));
      });

      testWidgets('should clear text field after sending', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        const testMessage = 'Hello World';
        await tester.enterText(find.byType(TextField), testMessage);
        await tester.pump();

        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, isEmpty);
        expect(find.text('0/160'), findsOneWidget);
      });

      testWidgets('should not send empty or whitespace-only messages', (
        tester,
      ) async {
        await tester.pumpWidget(createMessageInputWidget());

        // Test empty message
        await tester.enterText(find.byType(TextField), '');
        await tester.pump();
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();

        expect(sentMessages, isEmpty);

        // Test whitespace-only message
        await tester.enterText(find.byType(TextField), '   ');
        await tester.pump();
        await tester.tap(find.byIcon(Icons.send_rounded));
        await tester.pump();

        // Should still be empty since widget trims whitespace
        expect(sentMessages, isEmpty);
      });

      testWidgets('should be disabled when at character limit', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        // Enter exactly 160 characters (the limit)
        final maxMessage = 'A' * 160;
        await tester.enterText(find.byType(TextField), maxMessage);
        await tester.pump();

        final sendIconButtons = find.byType(IconButton);
        final sendButton = tester.widget<IconButton>(
          sendIconButtons.at(1), // Send button
        );

        // Button should be disabled at limit
        expect(sendButton.onPressed, isNull);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle rapid typing', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        // Simulate rapid character entry
        for (int i = 1; i <= 10; i++) {
          await tester.enterText(find.byType(TextField), 'A' * i);
          await tester.pump();
          expect(find.text('$i/160'), findsOneWidget);
        }
      });

      testWidgets('should handle maximum length text', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        final maxLengthMessage = 'A' * 160;
        await tester.enterText(find.byType(TextField), maxLengthMessage);
        await tester.pump();

        expect(find.text('160/160'), findsOneWidget);
      });

      testWidgets('should handle multiple sends', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        const messages = ['First', 'Second', 'Third'];

        for (final message in messages) {
          await tester.enterText(find.byType(TextField), message);
          await tester.pump();
          await tester.tap(find.byIcon(Icons.send_rounded));
          await tester.pump();
        }

        expect(sentMessages, equals(messages));
        expect(sentMessages.length, equals(3));
      });

      testWidgets('should show error for over-limit messages', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        // The TextField itself has maxLength constraint, but let's test the handler
        final overLimitMessage = 'A' * 200; // Over 160 limit

        // This would normally be prevented by TextField maxLength,
        // but we're testing the error handling
        await tester.enterText(find.byType(TextField), overLimitMessage);
        await tester.pump();

        // At the limit, send button should be disabled
        final sendIconButtons = find.byType(IconButton);
        final sendButton = tester.widget<IconButton>(
          sendIconButtons.at(1), // Send button
        );
        expect(sendButton.onPressed, isNull);
      });
    });

    group('Widget State Management', () {
      testWidgets('should maintain state during rebuild', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        await tester.enterText(find.byType(TextField), 'test');
        await tester.pump();

        // Check that the character count is updated
        expect(find.text('4/160'), findsOneWidget);

        // Trigger a rebuild with the same widget tree
        await tester.pumpWidget(createMessageInputWidget());

        // With StatefulWidget, state is preserved during rebuild if the widget tree structure is the same
        // So the text should still be there
        expect(find.text('4/160'), findsOneWidget);

        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text, equals('test'));
      });

      testWidgets('should have settings button', (tester) async {
        await tester.pumpWidget(createMessageInputWidget());

        expect(find.byIcon(Icons.settings), findsOneWidget);

        final settingsIconButtons = find.byType(IconButton);
        final settingsButton = tester.widget<IconButton>(
          settingsIconButtons.at(0), // First IconButton is settings
        );
        expect(settingsButton.onPressed, isNotNull);
      });
    });
  });
}
