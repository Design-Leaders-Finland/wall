// Avatar service for generating consistent user avatars
// Creates deterministic avatars based on user UUIDs using colors, icons, and shapes
import 'package:flutter/material.dart';

class AvatarService {
  // Generate a consistent avatar based on a UUID seed
  // Returns an avatar configuration map with colors and shapes
  static Map<String, dynamic> generateAvatar(String seed) {
    try {
      // Split UUID into parts for consistent generation
      final uuidParts = seed.split('-');
      if (uuidParts.length != 5) {
        throw Exception('Invalid UUID format');
      }

      // Use different parts of UUID for different avatar attributes
      final backgroundColorIndex = _getIndexFromUuidPart(
        uuidParts[0],
        _avatarBackgroundColors.length,
      );
      final iconIndex = _getIndexFromUuidPart(
        uuidParts[1],
        _avatarIcons.length,
      );
      final iconColorIndex = _getIndexFromUuidPart(
        uuidParts[2],
        _avatarIconColors.length,
      );
      final shapeIndex = _getIndexFromUuidPart(
        uuidParts[3],
        _avatarShapes.length,
      );

      return {
        'backgroundColor': _avatarBackgroundColors[backgroundColorIndex],
        'icon': _avatarIcons[iconIndex],
        'iconColor': _avatarIconColors[iconColorIndex],
        'shape': _avatarShapes[shapeIndex],
      };
    } catch (e) {
      // Fallback avatar for invalid UUIDs
      return {
        'backgroundColor': _avatarBackgroundColors[0],
        'icon': _avatarIcons[0],
        'iconColor': _avatarIconColors[0],
        'shape': _avatarShapes[0],
      };
    }
  }

  // Convert a UUID part (hex string) to an index for selection
  static int _getIndexFromUuidPart(String uuidPart, int vocabularyLength) {
    final hexValue = int.parse(uuidPart, radix: 16);
    return hexValue % vocabularyLength;
  }

  // Avatar color palette (background colors)
  static const List<Color> _avatarBackgroundColors = [
    Color(0xFFE3F2FD), // Light Blue
    Color(0xFFE8F5E8), // Light Green
    Color(0xFFFFF3E0), // Light Orange
    Color(0xFFF3E5F5), // Light Purple
    Color(0xFFFFEBEE), // Light Red
    Color(0xFFF9FBE7), // Light Lime
    Color(0xFFE0F2F1), // Light Teal
    Color(0xFFFFF8E1), // Light Yellow
    Color(0xFFEDE7F6), // Light Deep Purple
    Color(0xFFE1F5FE), // Light Cyan
    Color(0xFFF1F8E9), // Light Light Green
    Color(0xFFFFF3E0), // Light Deep Orange
    Color(0xFFE8EAF6), // Light Indigo
    Color(0xFFF3E5F5), // Light Pink
    Color(0xFFE0F7FA), // Light Light Blue
    Color(0xFFF9FBE7), // Light Yellow Green
  ];

  // Avatar icon colors (contrasting with backgrounds)
  static const List<Color> _avatarIconColors = [
    Color(0xFF1976D2), // Blue
    Color(0xFF388E3C), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFF7B1FA2), // Purple
    Color(0xFFD32F2F), // Red
    Color(0xFF689F38), // Lime
    Color(0xFF00796B), // Teal
    Color(0xFFFBC02D), // Yellow
    Color(0xFF512DA8), // Deep Purple
    Color(0xFF0097A7), // Cyan
    Color(0xFF558B2F), // Light Green
    Color(0xFFE64A19), // Deep Orange
    Color(0xFF303F9F), // Indigo
    Color(0xFFAD1457), // Pink
    Color(0xFF0288D1), // Light Blue
    Color(0xFF9E9D24), // Yellow Green
  ];

  // Avatar icons (Material Icons)
  static const List<IconData> _avatarIcons = [
    Icons.person,
    Icons.star,
    Icons.favorite,
    Icons.face,
    Icons.pets,
    Icons.lightbulb,
    Icons.music_note,
    Icons.eco,
    Icons.rocket_launch,
    Icons.diamond,
    Icons.local_fire_department,
    Icons.wb_sunny,
    Icons.nights_stay,
    Icons.flash_on,
    Icons.water_drop,
    Icons.auto_awesome,
    Icons.psychology,
    Icons.explore,
    Icons.sports_esports,
    Icons.palette,
    Icons.camera_alt,
    Icons.headphones,
    Icons.brush,
    Icons.code,
    Icons.science,
    Icons.sports_soccer,
    Icons.restaurant,
    Icons.beach_access,
    Icons.flight,
    Icons.directions_bike,
    Icons.hiking,
    Icons.sailing,
  ];

  // Avatar shapes
  static const List<String> _avatarShapes = ['circle', 'roundedSquare'];
}
