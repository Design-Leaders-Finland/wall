import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/widgets/auth_error_widget.dart';

void main() {
  group('AuthErrorWidget Tests', () {
    group('Widget Rendering', () {
      testWidgets('should display error message and retry button', (
        tester,
      ) async {
        // Arrange
        const errorMessage = 'Test authentication error';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthErrorWidget(errorMessage: errorMessage, onRetry: () {}),
            ),
          ),
        );

        // Assert
        expect(find.text('Unable to Sign In'), findsOneWidget);
        expect(find.text(errorMessage), findsOneWidget);
        expect(
          find.text('Please check your internet connection and try again.'),
          findsOneWidget,
        );
        expect(find.text('Retry Sign In'), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('should call onRetry when retry button is pressed', (
        tester,
      ) async {
        // Arrange
        bool retryPressed = false;
        const errorMessage = 'Test error';

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthErrorWidget(
                errorMessage: errorMessage,
                onRetry: () => retryPressed = true,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('Retry Sign In'));
        await tester.pump();

        // Assert
        expect(retryPressed, isTrue);
      });
    });

    group('UI Layout', () {
      testWidgets('should have proper card layout with margins and padding', (
        tester,
      ) async {
        // Arrange
        const errorMessage = 'Test error';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthErrorWidget(errorMessage: errorMessage, onRetry: () {}),
            ),
          ),
        );

        // Assert
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(Column), findsAtLeastNWidgets(1));
        expect(find.text('Retry Sign In'), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });

      testWidgets('should be centered on screen', (tester) async {
        // Arrange
        const errorMessage = 'Test error';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AuthErrorWidget(errorMessage: errorMessage, onRetry: () {}),
            ),
          ),
        );

        // Assert
        expect(find.byType(Center), findsAtLeastNWidgets(1));
      });
    });

    group('Theme Integration', () {
      testWidgets('should use theme colors correctly', (tester) async {
        // Arrange
        const errorMessage = 'Test error';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: AuthErrorWidget(errorMessage: errorMessage, onRetry: () {}),
            ),
          ),
        );

        // Assert - widget should build without errors
        expect(find.byType(AuthErrorWidget), findsOneWidget);
      });

      testWidgets('should work with dark theme', (tester) async {
        // Arrange
        const errorMessage = 'Test error';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: AuthErrorWidget(errorMessage: errorMessage, onRetry: () {}),
            ),
          ),
        );

        // Assert - widget should build without errors
        expect(find.byType(AuthErrorWidget), findsOneWidget);
      });
    });
  });
}
