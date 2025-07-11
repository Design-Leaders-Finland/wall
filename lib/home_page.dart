import 'package:flutter/material.dart';

import 'models/message.dart';
import 'services/auth_service.dart';
import 'services/message_service.dart';
import 'widgets/message_input.dart';
import 'widgets/message_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  final MessageService _messageService = MessageService();
  
  List<Message> _messages = [];
  DateTime? _lastMessageSentTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _isLoading = true);
    
    // Sign in anonymously
    final user = await _authService.signInAnonymously();
    if (user == null) {
      _showMessage('Failed to sign in. Please restart the app.');
      return;
    }
    
    // Setup message callback
    _messageService.onNewMessage = (newMessage) {
      setState(() {
        _messages.add(newMessage);
        _sortMessages();
      });
    };
    
    // Initialize realtime subscription
    _messageService.initRealtimeSubscription();
    
    // Fetch initial messages
    await _fetchMessages();
    
    setState(() => _isLoading = false);
  }

  Future<void> _fetchMessages() async {
    final messages = await _messageService.fetchMessages();
    setState(() {
      _messages = messages;
      _sortMessages();
    });
  }

  void _sortMessages() {
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> _handleSendMessage(String content) async {
    final user = _authService.getCurrentUser();
    if (user == null) {
      _showMessage('User not authenticated. Please restart the app.');
      return;
    }

    // Rate limit check
    if (_lastMessageSentTime != null) {
      final Duration elapsed = DateTime.now().difference(_lastMessageSentTime!);
      if (elapsed.inMinutes < MessageService.messageCooldownMinutes) {
        final int remainingSeconds = (MessageService.messageCooldownMinutes * 60) - elapsed.inSeconds;
        _showMessage('Please wait $remainingSeconds seconds before sending another message.');
        return;
      }
    }

    final success = await _messageService.sendMessage(
      content: content,
      userId: user.id,
      lastMessageSentTime: _lastMessageSentTime,
    );

    if (success) {
      setState(() {
        _lastMessageSentTime = DateTime.now();
      });
    } else {
      _showMessage('Failed to send message. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _messageService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter to only visible messages (not expired)
    final visibleMessages = _messageService.getVisibleMessages(_messages);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WALL', 
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Menu functionality would go here
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Line under app bar
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Theme.of(context).colorScheme.outlineVariant.withAlpha(128),
                ),
                // Message list
                Expanded(
                  child: MessageList(messages: visibleMessages),
                ),
                // Message input at bottom
                MessageInput(onSendMessage: _handleSendMessage),
              ],
            ),
    );
  }
}
