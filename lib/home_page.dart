import 'package:flutter/material.dart';

import 'models/message.dart';
import 'services/auth_service.dart';
import 'services/message_service.dart';
import 'exceptions/auth_exception.dart';
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

  // Track auth failure state
  bool _authFailed = false;
  String _authErrorMessage = '';
  
  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _authFailed = false;
      _authErrorMessage = '';
    });
    
    try {
      // Sign in anonymously
      final user = await _authService.signInAnonymously();
      if (user == null) {
        // Authentication failed
        setState(() {
          _authFailed = true;
          _authErrorMessage = 'Failed to sign in anonymously.';
          _isLoading = false;
        });
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
    } on AuthFailedException catch (e) {
      // Handle authentication-specific errors
      setState(() {
        _authFailed = true;
        _authErrorMessage = e.toString();
        _isLoading = false;
      });
    } catch (e) {
      // Handle any other errors during initialization
      setState(() {
        _authFailed = true;
        _authErrorMessage = 'Error during initialization: ${e.toString()}';
        _isLoading = false;
      });
    }
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
      body: _buildBody(context, visibleMessages),
    );
  }
  
  Widget _buildBody(BuildContext context, List<Message> visibleMessages) {
    // Show loading indicator
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Show auth error UI
    if (_authFailed) {
      return Container(
        color: Theme.of(context).colorScheme.errorContainer.withAlpha(13), // ~5% opacity
        child: Center(
          child: Card(
            margin: const EdgeInsets.all(24.0),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: Theme.of(context).colorScheme.errorContainer,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to Sign In',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _authErrorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your internet connection and try again.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Reload the app by reinitializing
                      _initialize();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry Sign In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    
    // Show normal UI when authenticated
    return Column(
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
    );
  }
}
