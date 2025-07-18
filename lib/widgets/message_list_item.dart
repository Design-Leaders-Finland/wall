import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageListItem extends StatelessWidget {
  final Message message;

  const MessageListItem({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final formattedTime = message.formatTime(locale);
    final colorScheme = Theme.of(context).colorScheme;

    // Set colors based on whether the message is from current user
    final containerColor = message.isFromCurrentUser
        ? colorScheme.primaryContainer.withAlpha(
            76,
          ) // 0.3 opacity is approximately 76/255
        : Colors.transparent;

    final userName = message.isFromCurrentUser ? "YOU" : message.shortUserId;

    final userNameColor = message.isFromCurrentUser
        ? colorScheme.primary
        : colorScheme.onSurface;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: containerColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with user name and timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: userNameColor,
                        ),
                      ),
                      if (message.isFromCurrentUser)
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Icon(
                            Icons.person,
                            size: 14,
                            color: colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Message content
              Text(
                message.content,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: message.isFromCurrentUser
                      ? FontWeight.w500
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        // Divider between messages
        Divider(
          height: 1,
          color: Theme.of(context).colorScheme.outlineVariant.withAlpha(128),
        ),
      ],
    );
  }
}
