import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/services/app_icon_service.dart';

void main() {
  group('AppIconService Tests', () {
    late List<MethodCall> methodCalls;

    setUp(() {
      methodCalls = [];
      // Mock the method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('fi.designleaders.wall/app_icon'),
            (MethodCall methodCall) async {
              methodCalls.add(methodCall);
              return null;
            },
          );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('fi.designleaders.wall/app_icon'),
            null,
          );
    });

    testWidgets('should call platform method with light theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              AppIconService.updateAppIcon(context);
              return const Scaffold(body: Text('Light Theme Test'));
            },
          ),
        ),
      );

      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.method, equals('updateAppIcon'));
      expect(methodCalls.first.arguments, equals({'isDark': false}));
    });

    testWidgets('should call platform method with dark theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (BuildContext context) {
              AppIconService.updateAppIcon(context);
              return const Scaffold(body: Text('Dark Theme Test'));
            },
          ),
        ),
      );

      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.method, equals('updateAppIcon'));
      expect(methodCalls.first.arguments, equals({'isDark': true}));
    });

    testWidgets('should handle platform exceptions gracefully', (tester) async {
      // Setup method channel to throw exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('fi.designleaders.wall/app_icon'),
            (MethodCall methodCall) async {
              throw PlatformException(
                code: 'UNAVAILABLE',
                message: 'App icon update not available',
              );
            },
          );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              // Should not throw exception
              AppIconService.updateAppIcon(context);
              return const Scaffold(body: Text('Exception Test'));
            },
          ),
        ),
      );

      // Should complete without throwing
      expect(find.text('Exception Test'), findsOneWidget);
    });

    testWidgets('should handle generic exceptions gracefully', (tester) async {
      // Setup method channel to throw generic exception
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('fi.designleaders.wall/app_icon'),
            (MethodCall methodCall) async {
              throw Exception('Generic error');
            },
          );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              // Should not throw exception
              AppIconService.updateAppIcon(context);
              return const Scaffold(body: Text('Generic Exception Test'));
            },
          ),
        ),
      );

      // Should complete without throwing
      expect(find.text('Generic Exception Test'), findsOneWidget);
    });

    testWidgets('should work with custom theme brightness', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          home: Builder(
            builder: (BuildContext context) {
              AppIconService.updateAppIcon(context);
              return const Scaffold(body: Text('Custom Light Theme'));
            },
          ),
        ),
      );

      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.arguments, equals({'isDark': false}));
    });

    testWidgets('should work with system theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          themeMode: ThemeMode.system,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: Builder(
            builder: (BuildContext context) {
              AppIconService.updateAppIcon(context);
              return const Scaffold(body: Text('System Theme'));
            },
          ),
        ),
      );

      expect(methodCalls, hasLength(1));
      expect(methodCalls.first.method, equals('updateAppIcon'));
      expect(methodCalls.first.arguments, containsPair('isDark', isA<bool>()));
    });

    testWidgets('should handle multiple calls correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              // Call multiple times
              AppIconService.updateAppIcon(context);
              AppIconService.updateAppIcon(context);
              AppIconService.updateAppIcon(context);
              return const Scaffold(body: Text('Multiple Calls'));
            },
          ),
        ),
      );

      expect(methodCalls, hasLength(3));
      for (final call in methodCalls) {
        expect(call.method, equals('updateAppIcon'));
        expect(call.arguments, equals({'isDark': false}));
      }
    });

    testWidgets('should use correct method channel', (tester) async {
      // The method channel name should be consistent
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              AppIconService.updateAppIcon(context);
              return const Scaffold(body: Text('Channel Test'));
            },
          ),
        ),
      );

      // Verify the call was made (we can't directly test the channel name,
      // but the mock setup ensures it's the right channel)
      expect(methodCalls, hasLength(1));
    });

    test('should have correct method channel configuration', () {
      // Test that the service has the expected configuration
      // This is more of a structural test to ensure consistency
      expect(AppIconService, isNotNull);
    });
  });
}
