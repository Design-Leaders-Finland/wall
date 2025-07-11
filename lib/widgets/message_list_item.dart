import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageListItem extends StatelessWidget {
  final Message message;

  const MessageListItem({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final formattedTime = message.formatTime(locale);
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with user name and timestamp
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    message.shortUserId,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  color: Theme.of(context).colorScheme.onSurface,
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
