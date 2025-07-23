import 'package:flutter/material.dart';

/// Widget that displays offline indicator and reconnect button
class OfflineIndicator extends StatelessWidget {
  final String displayText;
  final VoidCallback onReconnect;

  const OfflineIndicator({
    super.key,
    required this.displayText,
    required this.onReconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(
              displayText,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            labelStyle: TextStyle(
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            avatar: Icon(
              Icons.cloud_off,
              size: 16,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            visualDensity: VisualDensity.compact,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: onReconnect,
            tooltip: 'Try to reconnect',
          ),
        ],
      ),
    );
  }
}
