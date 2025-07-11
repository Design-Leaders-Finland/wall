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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              maxLength: MessageService.messageMaxLength,
              decoration: const InputDecoration(
                hintText: 'Enter your message...',
                border: OutlineInputBorder(),
                counterText: '', // Hide default character counter
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _handleSend,
          ),
        ],
      ),
    );
  }
}
