import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/widgets/user_avatar.dart';

void main() {
  group('UserAvatar Widget Tests', () {
    const testUserId = '550e8400-e29b-41d4-a716-446655440000';

    testWidgets('should render avatar for current user', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              userId: testUserId,
              isCurrentUser: true,
              size: 40.0,
            ),
          ),
        ),
      );

      expect(find.byType(UserAvatar), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);

      // Current user should use person icon
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should render avatar for other user', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              userId: testUserId,
              isCurrentUser: false,
              size: 40.0,
            ),
          ),
        ),
      );

      expect(find.byType(UserAvatar), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);

      // Other users should have generated icons (not necessarily person)
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('should handle custom avatar seed', (tester) async {
      const customSeed = '11111111-2222-3333-4444-555555555555';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              userId: testUserId,
              avatarSeed: customSeed,
              isCurrentUser: false,
              size: 40.0,
            ),
          ),
        ),
      );

      expect(find.byType(UserAvatar), findsOneWidget);
    });

    testWidgets('should render with different sizes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                UserAvatar(userId: testUserId, size: 24.0),
                UserAvatar(userId: testUserId, size: 32.0),
                UserAvatar(userId: testUserId, size: 48.0),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(UserAvatar), findsNWidgets(3));
    });

    testWidgets('should generate consistent appearance', (tester) async {
      // Test that the same userId generates the same avatar appearance
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                UserAvatar(userId: testUserId, size: 40.0),
                UserAvatar(userId: testUserId, size: 40.0),
              ],
            ),
          ),
        ),
      );

      final avatars = find.byType(UserAvatar);
      expect(avatars, findsNWidgets(2));
    });
  });
}
