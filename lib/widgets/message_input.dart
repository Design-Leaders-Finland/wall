import 'package:flutter/material.dart';
import '../services/message_service.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;

  const MessageInput({super.key, required this.onSendMessage});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(_updateCharCount);
  }

  void _updateCharCount() {
    setState(() {
      _characterCount = _messageController.text.length;
    });
  }

  void _handleSend() {
    final messageContent = _messageController.text.trim();
    if (messageContent.isNotEmpty &&
        messageContent.length <= MessageService.messageMaxLength) {
      widget.onSendMessage(messageContent);
      _messageController.clear();
    } else if (messageContent.length > MessageService.messageMaxLength) {
      // Show an error message if the user somehow bypasses the UI constraints
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Message exceeds maximum length of ${MessageService.messageMaxLength} characters',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_updateCharCount);
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isNearLimit =
        _characterCount >
        MessageService.messageMaxLength * 0.8; // Over 80% of limit
    final bool isAtLimit = _characterCount >= MessageService.messageMaxLength;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Settings icon on the left
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Settings functionality would go here
                },
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              // Message input field
              Expanded(
                child: TextField(
                  controller: _messageController,
                  maxLength: MessageService.messageMaxLength,
                  decoration: InputDecoration(
                    hintText: 'Your message',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant.withAlpha(179),
                    ),
                    border: InputBorder.none,
                    counterText: '', // Hide default character counter
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                  ),
                  onSubmitted: (_) {
                    if (!isAtLimit) {
                      _handleSend();
                    }
                  },
                  textInputAction: TextInputAction.send,
                ),
              ),
              // Send button
              IconButton(
                icon: const Icon(Icons.send_rounded),
                onPressed: isAtLimit ? null : _handleSend,
                color: isAtLimit
                    ? colorScheme.onSurfaceVariant.withAlpha(
                        128,
                      ) // Disabled color
                    : colorScheme.primary,
                tooltip: 'Send message',
                splashRadius: 24.0,
                iconSize: 26.0,
              ),
            ],
          ),
          // Character counter row
          Padding(
            padding: const EdgeInsets.only(
              left: 56.0,
              right: 16.0,
              bottom: 4.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '$_characterCount/${MessageService.messageMaxLength}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isNearLimit
                        ? (isAtLimit
                              ? colorScheme.error
                              : colorScheme.error.withAlpha(200))
                        : colorScheme.onSurfaceVariant.withAlpha(150),
                    fontWeight: isNearLimit
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
