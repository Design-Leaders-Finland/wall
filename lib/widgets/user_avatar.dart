// User avatar widget for displaying consistent user avatars
// Generates deterministic avatars based on user UUIDs
import 'package:flutter/material.dart';
import '../services/avatar_service.dart';

class UserAvatar extends StatelessWidget {
  final String userId;
  final String? avatarSeed;
  final double size;
  final bool isCurrentUser;

  const UserAvatar({
    super.key,
    required this.userId,
    this.avatarSeed,
    this.size = 32.0,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    final seed = avatarSeed ?? userId;
    final avatarConfig = AvatarService.generateAvatar(seed);

    final backgroundColor = avatarConfig['backgroundColor'] as Color;
    final icon = avatarConfig['icon'] as IconData;
    final iconColor = avatarConfig['iconColor'] as Color;
    final shape = avatarConfig['shape'] as String;

    // For current user, use a special styling
    if (isCurrentUser) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: shape == 'roundedSquare'
              ? BorderRadius.circular(size * 0.2)
              : null,
          color: Theme.of(context).colorScheme.primary,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        child: Icon(
          Icons.person,
          size: size * 0.6,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

    // For other users, use the generated avatar
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: shape == 'roundedSquare'
            ? BorderRadius.circular(size * 0.2)
            : null,
        color: backgroundColor,
        border: Border.all(color: iconColor.withAlpha(100), width: 1.0),
      ),
      child: Icon(icon, size: size * 0.6, color: iconColor),
    );
  }
}
