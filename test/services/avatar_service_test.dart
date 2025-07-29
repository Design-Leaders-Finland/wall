import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wall/services/avatar_service.dart';

void main() {
  group('AvatarService Tests', () {
    const testUuid = '550e8400-e29b-41d4-a716-446655440000';
    const invalidUuid = 'invalid-uuid';

    test('should generate consistent avatar for valid UUID', () {
      final avatar1 = AvatarService.generateAvatar(testUuid);
      final avatar2 = AvatarService.generateAvatar(testUuid);

      // Should be identical
      expect(avatar1, equals(avatar2));

      // Should contain required keys
      expect(avatar1.containsKey('backgroundColor'), isTrue);
      expect(avatar1.containsKey('icon'), isTrue);
      expect(avatar1.containsKey('iconColor'), isTrue);
      expect(avatar1.containsKey('shape'), isTrue);
    });

    test('should generate different avatars for different UUIDs', () {
      const uuid1 = '550e8400-e29b-41d4-a716-446655440000';
      const uuid2 = '11111111-2222-3333-4444-555555555555';

      final avatar1 = AvatarService.generateAvatar(uuid1);
      final avatar2 = AvatarService.generateAvatar(uuid2);

      // Should be different (at least one property should differ)
      expect(avatar1, isNot(equals(avatar2)));
    });

    test('should handle invalid UUID gracefully', () {
      final avatar = AvatarService.generateAvatar(invalidUuid);

      // Should return fallback avatar
      expect(avatar.containsKey('backgroundColor'), isTrue);
      expect(avatar.containsKey('icon'), isTrue);
      expect(avatar.containsKey('iconColor'), isTrue);
      expect(avatar.containsKey('shape'), isTrue);
    });

    test('should generate avatar with valid values', () {
      final avatar = AvatarService.generateAvatar(testUuid);

      // Check types and valid values
      expect(avatar['backgroundColor'], isA<Color>());
      expect(avatar['icon'], isA<IconData>());
      expect(avatar['iconColor'], isA<Color>());
      expect(avatar['shape'], isA<String>());

      // Check shape is valid
      final shape = avatar['shape'] as String;
      expect(['circle', 'roundedSquare'].contains(shape), isTrue);
    });
  });
}
