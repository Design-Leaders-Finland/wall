import 'package:flutter/material.dart';
import '../services/message_service.dart';

class MessageInput extends StatefulWidget {
  final Function(String) onSendMessage;
  
  const MessageInput({
    super.key,
    required this.onSendMessage,
  });

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final TextEditingController _messageController = TextEditingController();
  
  void _handleSend() {
    final messageContent = _messageController.text.trim();
    if (messageContent.isNotEmpty) {
      widget.onSendMessage(messageContent);
      _messageController.clear();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
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
      child: Row(
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
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(179),
                ),
                border: InputBorder.none,
                counterText: '', // Hide default character counter
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
        ],
      ),
    );
  }
}
