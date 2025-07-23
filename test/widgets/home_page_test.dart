import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/home_page.dart';

void main() {
  group('HomePage Tests', () {
    group('Widget Creation', () {
      testWidgets('should create HomePage widget', (tester) async {
        // Act
        await tester.pumpWidget(const MaterialApp(home: HomePage()));

        // Assert
        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('should display app bar with WALL title', (tester) async {
        // Act
        await tester.pumpWidget(const MaterialApp(home: HomePage()));

        // Assert
        expect(find.text('WALL'), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byIcon(Icons.menu), findsOneWidget);
      });
    });

    group('Loading State', () {
      testWidgets('should show loading indicator initially', (tester) async {
        // Act
        await tester.pumpWidget(const MaterialApp(home: HomePage()));

        // Assert
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });
    });

    group('UI Structure', () {
      testWidgets('should have proper scaffold structure', (tester) async {
        // Act
        await tester.pumpWidget(const MaterialApp(home: HomePage()));

        // Assert
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });

      testWidgets('should have menu button in app bar', (tester) async {
        // Act
        await tester.pumpWidget(const MaterialApp(home: HomePage()));

        // Assert
        expect(find.byIcon(Icons.menu), findsOneWidget);
      });
    });

    group('Theme Integration', () {
      testWidgets('should work with light theme', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(theme: ThemeData.light(), home: const HomePage()),
        );

        // Assert
        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('should work with dark theme', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(theme: ThemeData.dark(), home: const HomePage()),
        );

        // Assert
        expect(find.byType(HomePage), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle widget creation without errors', (
        tester,
      ) async {
        // Act & Assert - Should not throw
        await tester.pumpWidget(const MaterialApp(home: HomePage()));

        expect(find.byType(HomePage), findsOneWidget);
      });
    });
  });
}
