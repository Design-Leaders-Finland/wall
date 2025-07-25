import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/home_page.dart';
import '../test_helpers.dart';

void main() {
  group('HomePage Tests', () {
    setUpAll(() async {
      await TestHelpers.initializeSupabase();
    });

    group('Widget Creation', () {
      testWidgets('should create HomePage widget', (tester) async {
        // Act
        await tester.pumpWidget(const MaterialApp(home: HomePage()));

        // Give some time for initialization but don't wait for all async operations
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Just check that the widget was created
        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('should have basic structure', (tester) async {
        // Act
        await tester.pumpWidget(const MaterialApp(home: HomePage()));
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Check for basic UI elements that should exist immediately
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('UI Structure', () {
      testWidgets('should have proper scaffold structure', (tester) async {
        // Act
        await tester.pumpWidget(const MaterialApp(home: HomePage()));
        await tester.pump(const Duration(milliseconds: 100));

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('Theme Integration', () {
      testWidgets('should work with Material theme', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(theme: ThemeData.light(), home: const HomePage()),
        );
        await tester.pump(const Duration(milliseconds: 100));

        // Assert
        expect(find.byType(HomePage), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });
  });
}
