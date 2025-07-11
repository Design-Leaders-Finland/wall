import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;
  
  const MessageList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true, // Show latest messages at the bottom
      itemCount: messages.length,
      itemBuilder: (context, index) {
        // Display in reverse order (newest at bottom)
        final message = messages[messages.length - 1 - index];
        final formattedTime = DateFormat('HH:mm').format(message.createdAt.toLocal());
        
        return ListTile(
          title: Text(message.content),
          subtitle: Text('$formattedTime - ${message.shortUserId}'),
        );
      },
    );
  }
}
