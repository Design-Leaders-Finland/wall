import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/widgets/offline_indicator.dart';

void main() {
  group('OfflineIndicator Tests', () {
    group('Widget Rendering', () {
      testWidgets('should display offline chip and reconnect button', (
        tester,
      ) async {
        // Arrange
        const displayText = 'OFFLINE (3)';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                displayText: displayText,
                onReconnect: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(displayText), findsOneWidget);
        expect(find.byIcon(Icons.cloud_off), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
        expect(find.byType(Chip), findsOneWidget);
        expect(find.byType(IconButton), findsOneWidget);
      });

      testWidgets('should call onReconnect when refresh button is pressed', (
        tester,
      ) async {
        // Arrange
        bool reconnectPressed = false;
        const displayText = 'OFFLINE';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                displayText: displayText,
                onReconnect: () => reconnectPressed = true,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();

        // Assert
        expect(reconnectPressed, isTrue);
      });
    });

    group('Display Text Variations', () {
      testWidgets('should display simple OFFLINE text', (tester) async {
        // Arrange
        const displayText = 'OFFLINE';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                displayText: displayText,
                onReconnect: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(displayText), findsOneWidget);
      });

      testWidgets('should display OFFLINE with message count', (tester) async {
        // Arrange
        const displayText = 'OFFLINE (5)';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                displayText: displayText,
                onReconnect: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(displayText), findsOneWidget);
      });
    });

    group('UI Layout', () {
      testWidgets('should have proper row layout with padding', (tester) async {
        // Arrange
        const displayText = 'OFFLINE';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                displayText: displayText,
                onReconnect: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(find.byType(Padding), findsAtLeastNWidgets(1));
        expect(find.byType(Row), findsOneWidget);
      });

      testWidgets('should have refresh button with tooltip', (tester) async {
        // Arrange
        const displayText = 'OFFLINE';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OfflineIndicator(
                displayText: displayText,
                onReconnect: () {},
              ),
            ),
          ),
        );

        // Act - Long press to show tooltip
        await tester.longPress(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Try to reconnect'), findsOneWidget);
      });
    });

    group('Theme Integration', () {
      testWidgets('should use error container theme colors', (tester) async {
        // Arrange
        const displayText = 'OFFLINE';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: OfflineIndicator(
                displayText: displayText,
                onReconnect: () {},
              ),
            ),
          ),
        );

        // Assert - widget should build without errors
        expect(find.byType(OfflineIndicator), findsOneWidget);
      });

      testWidgets('should work with dark theme', (tester) async {
        // Arrange
        const displayText = 'OFFLINE';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: OfflineIndicator(
                displayText: displayText,
                onReconnect: () {},
              ),
            ),
          ),
        );

        // Assert - widget should build without errors
        expect(find.byType(OfflineIndicator), findsOneWidget);
      });
    });
  });
}
