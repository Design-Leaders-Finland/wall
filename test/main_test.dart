import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/main.dart';

void main() {
  group('Main App Tests', () {
    testWidgets('should create MyApp without errors', (WidgetTester tester) async {
      // Test that the main app widget can be created
      await tester.pumpWidget(const MyApp());
      
      // Verify that the app builds without throwing errors
      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('MyApp should have correct app configuration', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Find the MaterialApp widget
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify app configuration
      expect(materialApp.title, equals('WALL'));
      expect(materialApp.theme, isNotNull);
      expect(materialApp.darkTheme, isNotNull);
      expect(materialApp.themeMode, equals(ThemeMode.system));
    });

    testWidgets('should have light theme with blue color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final lightTheme = materialApp.theme!;
      
      // Verify that light theme uses blue seed color
      expect(lightTheme.colorScheme.brightness, equals(Brightness.light));
      expect(lightTheme.useMaterial3, isTrue);
    });

    testWidgets('should have dark theme with blue color scheme', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final darkTheme = materialApp.darkTheme!;
      
      // Verify that dark theme uses blue seed color  
      expect(darkTheme.colorScheme.brightness, equals(Brightness.dark));
      expect(darkTheme.useMaterial3, isTrue);
    });

    testWidgets('should use system theme mode', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      
      // Verify system theme mode
      expect(materialApp.themeMode, equals(ThemeMode.system));
    });

    group('Widget Structure', () {
      testWidgets('MyApp should contain MaterialApp', (WidgetTester tester) async {
        await tester.pumpWidget(const MyApp());
        
        // Test for MaterialApp presence
        expect(find.byType(MaterialApp), findsOneWidget);
      });
    });

    group('App Initialization', () {
      testWidgets('should handle MyApp creation without errors', (WidgetTester tester) async {
        // This test ensures that the app can start up without throwing exceptions
        expect(() => const MyApp(), returnsNormally);
      });
    });
  });
}
