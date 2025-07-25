import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/widgets/theme_aware_icon_handler.dart';

void main() {
  group('ThemeAwareIconHandler Widget Tests', () {
    testWidgets('should render child widget', (tester) async {
      const childWidget = Text('Test Child');

      await tester.pumpWidget(
        const MaterialApp(home: ThemeAwareIconHandler(child: childWidget)),
      );

      expect(find.text('Test Child'), findsOneWidget);
      expect(find.byWidget(childWidget), findsOneWidget);
    });

    testWidgets('should maintain child widget structure', (tester) async {
      const childWidget = Scaffold(
        body: Center(
          child: Column(
            children: [Text('Header'), Text('Content'), Text('Footer')],
          ),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(home: ThemeAwareIconHandler(child: childWidget)),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });

    testWidgets('should handle theme changes', (tester) async {
      const childWidget = Text('Theme Test');

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const ThemeAwareIconHandler(child: childWidget),
        ),
      );

      expect(find.text('Theme Test'), findsOneWidget);

      // Change to dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const ThemeAwareIconHandler(child: childWidget),
        ),
      );

      expect(find.text('Theme Test'), findsOneWidget);
    });

    testWidgets('should handle nested widgets correctly', (tester) async {
      const nestedWidget = Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: Text('App Bar'),
        ),
        body: Center(
          child: ThemeAwareIconHandler(child: Text('Nested Content')),
        ),
      );

      await tester.pumpWidget(
        const MaterialApp(home: ThemeAwareIconHandler(child: nestedWidget)),
      );

      expect(find.text('App Bar'), findsOneWidget);
      expect(find.text('Nested Content'), findsOneWidget);
      expect(find.byType(ThemeAwareIconHandler), findsNWidgets(2));
    });

    testWidgets('should handle widget rebuilds', (tester) async {
      Widget buildTestWidget(String text) {
        return MaterialApp(home: ThemeAwareIconHandler(child: Text(text)));
      }

      await tester.pumpWidget(buildTestWidget('First'));
      expect(find.text('First'), findsOneWidget);

      await tester.pumpWidget(buildTestWidget('Second'));
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('First'), findsNothing);
    });

    testWidgets('should work with different child widget types', (
      tester,
    ) async {
      final childWidgets = [
        const Text('Text Widget'),
        const Icon(Icons.star),
        Container(
          width: 100,
          height: 100,
          color: Colors.blue,
          child: const Text('Container'),
        ),
        const Material(child: ListTile(title: Text('List Tile'))),
      ];

      for (final child in childWidgets) {
        await tester.pumpWidget(
          MaterialApp(home: ThemeAwareIconHandler(child: child)),
        );

        expect(find.byWidget(child), findsOneWidget);
      }
    });

    testWidgets('should handle stateful child widgets', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: ThemeAwareIconHandler(child: _TestStatefulWidget())),
      );

      expect(find.text('Counter: 0'), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Counter: 1'), findsOneWidget);
    });

    testWidgets('should properly dispose when removed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ThemeAwareIconHandler(child: Text('Disposable')),
        ),
      );

      expect(find.text('Disposable'), findsOneWidget);

      // Remove the widget
      await tester.pumpWidget(const SizedBox());

      // Should not find the widget anymore
      expect(find.text('Disposable'), findsNothing);
    });

    testWidgets('should handle rapid theme changes', (tester) async {
      const childWidget = Text('Rapid Theme Test');

      // Rapidly switch between themes
      for (int i = 0; i < 5; i++) {
        await tester.pumpWidget(
          MaterialApp(
            theme: i.isEven ? ThemeData.light() : ThemeData.dark(),
            home: const ThemeAwareIconHandler(child: childWidget),
          ),
        );

        await tester.pump(const Duration(milliseconds: 100));
        expect(find.text('Rapid Theme Test'), findsOneWidget);
      }
    });

    testWidgets('should maintain observer registration', (tester) async {
      const childWidget = Text('Observer Test');

      await tester.pumpWidget(
        const MaterialApp(home: ThemeAwareIconHandler(child: childWidget)),
      );

      expect(find.text('Observer Test'), findsOneWidget);

      // Trigger platform brightness change simulation
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/settings',
        null,
        (data) {},
      );

      await tester.pump();
      expect(find.text('Observer Test'), findsOneWidget);
    });
  });
}

class _TestStatefulWidget extends StatefulWidget {
  @override
  _TestStatefulWidgetState createState() => _TestStatefulWidgetState();
}

class _TestStatefulWidgetState extends State<_TestStatefulWidget> {
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('Counter: $_counter'),
          ElevatedButton(
            onPressed: () => setState(() => _counter++),
            child: const Text('Increment'),
          ),
        ],
      ),
    );
  }
}
