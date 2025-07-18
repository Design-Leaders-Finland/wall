import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/widgets/splash_screen.dart';

void main() {
  group('SplashScreen Widget Tests', () {
    testWidgets('should display WALL text', (WidgetTester tester) async {
      // Build the SplashScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify that the WALL text is displayed
      expect(find.text('WALL'), findsOneWidget);
    });

    testWidgets('should display circular progress indicator', (WidgetTester tester) async {
      // Build the SplashScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify that a CircularProgressIndicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (WidgetTester tester) async {
      // Build the SplashScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify the main structure
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
      // There might be multiple Center widgets due to the widget tree, so we'll check for at least one
      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });

    testWidgets('should use theme colors appropriately', (WidgetTester tester) async {
      const testColorScheme = ColorScheme.light(
        primary: Colors.blue,
        onPrimary: Colors.white,
        secondary: Colors.orange,
        surface: Colors.grey,
      );

      // Build the SplashScreen widget with a custom theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: testColorScheme,
            scaffoldBackgroundColor: Colors.grey[100],
          ),
          home: const SplashScreen(),
        ),
      );

      // Get the Container widget that should use the primary color
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(Container),
        ),
      );

      // Verify that the container uses theme colors
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(testColorScheme.primary));
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('should have correct text styling', (WidgetTester tester) async {
      const testColorScheme = ColorScheme.light(
        primary: Colors.blue,
        onPrimary: Colors.white,
      );

      // Build the SplashScreen widget with a custom theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: testColorScheme),
          home: const SplashScreen(),
        ),
      );

      // Find the Text widget
      final textWidget = tester.widget<Text>(find.text('WALL'));
      final textStyle = textWidget.style!;

      // Verify text properties
      expect(textStyle.color, equals(testColorScheme.onPrimary));
      expect(textStyle.fontSize, equals(32));
      expect(textStyle.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('should work with dark theme', (WidgetTester tester) async {
      // Build the SplashScreen widget with dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const SplashScreen(),
        ),
      );

      // Verify that the widget builds without errors
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('WALL'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should have proper widget dimensions', (WidgetTester tester) async {
      // Build the SplashScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Get the Container widget
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Column),
          matching: find.byType(Container),
        ),
      );

      // Verify container dimensions
      expect(container.constraints?.maxWidth, equals(150));
      expect(container.constraints?.maxHeight, equals(150));
    });

    testWidgets('should have proper spacing between elements', (WidgetTester tester) async {
      // Build the SplashScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Find the SizedBox widget
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));

      // Verify spacing
      expect(sizedBox.height, equals(24));
    });

    testWidgets('should center content properly', (WidgetTester tester) async {
      // Build the SplashScreen widget
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Find the Column widget
      final column = tester.widget<Column>(find.byType(Column));

      // Verify that content is centered
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });
  });
}
