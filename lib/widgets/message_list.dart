import 'package:flutter/material.dart';
import '../models/message.dart';
import 'message_list_item.dart';

class MessageList extends StatelessWidget {
  final List<Message> messages;
  
  const MessageList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: false, // Show oldest messages at the top as in the design
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageListItem(message: message);
      },
    );
  }
}
