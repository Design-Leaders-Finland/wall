import 'package:flutter/material.dart';

import 'models/message.dart';
import 'services/auth_service.dart';
import 'services/message_service.dart';
import 'exceptions/auth_exception.dart';
import 'utils/logger.dart';
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
  
  // Track connectivity state
  bool _isOffline = false;
  
  Future<void> _initialize() async {
    setState(() {
      _isLoading = true;
      _authFailed = false;
      _authErrorMessage = '';
      _isOffline = false;
    });
    
    try {
      // Sign in anonymously
      final user = await _authService.signInAnonymously();
      
      // Even if authentication fails (user is null), we'll try to proceed in read-only mode
      if (user == null) {
        AppLogger.warning('No user returned after sign in attempt. Continuing in read-only mode.');
      } else {
        AppLogger.info('Authentication successful for user: ${user.id}');
      }
      
      // Setup message callback
      _messageService.onNewMessage = (newMessage) {
        setState(() {
          _messages.add(newMessage);
          _sortMessages();
        });
      };
      
      // Initialize realtime subscription (even if auth failed)
      _messageService.initRealtimeSubscription();
      
      // Fetch initial messages (even if auth failed)
      await _fetchMessages();
      
      setState(() {
        _isLoading = false;
        _isOffline = !_messageService.isOnline;
      });
      
      if (_isOffline) {
        _showMessage('Working in offline mode. Messages are stored locally.');
      }
    } on AuthFailedException catch (e) {
      AppLogger.error('Authentication exception caught in HomePage', e);
      
      // Try to continue in read-only mode despite auth failure
      try {
        // Initialize realtime subscription anyway
        _messageService.initRealtimeSubscription();
        
        // Fetch initial messages - will use local storage if online fetch fails
        await _fetchMessages();
        
        setState(() {
          _isLoading = false;
          _isOffline = true; // Authentication failed, so we're in offline mode
          // Don't show auth failure screen if we have local messages
          _authFailed = false;
        });
        
        _showMessage('Authentication failed. Working in offline mode with local data.');
      } catch (innerError) {
        // Only if both auth and data fetching fail, show the error screen
        setState(() {
          _authFailed = true;
          _authErrorMessage = e.toString();
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Unexpected error during initialization', e);
      
      // Try to fetch local messages even if initialization failed
      try {
        await _fetchMessages();
        
        setState(() {
          _isLoading = false;
          _isOffline = true;
          _authFailed = false; // Don't show error if we have local messages
        });
        
        _showMessage('Connection error. Working in offline mode with local data.');
      } catch (localError) {
        // If even local storage fails, show the error screen
        setState(() {
          _authFailed = true;
          _authErrorMessage = 'Error during initialization: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchMessages() async {
    final messages = await _messageService.fetchMessages();
    setState(() {
      _messages = messages;
      _sortMessages();
      _isOffline = !_messageService.isOnline;
    });
  }
  
  // Try to reconnect to the server
  Future<void> _tryReconnect() async {
    if (!_isOffline) return;
    
    setState(() => _isLoading = true);
    
    try {
      final success = await _messageService.tryReconnect();
      if (success) {
        await _fetchMessages();
        _showMessage('Reconnected successfully. Your local messages will sync when you send a new message.');
      } else {
        _showMessage('Still offline. Your messages are saved locally.');
      }
    } catch (e) {
      AppLogger.error('Error trying to reconnect', e);
      _showMessage('Failed to reconnect. Still in offline mode.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortMessages() {
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> _handleSendMessage(String content) async {
    final user = _authService.getCurrentUser();
    
    if (user == null) {
      // Try to sign in again if no user is available
      AppLogger.info('No user found when trying to send message. Attempting to sign in...');
      try {
        final newUser = await _authService.signInAnonymously();
        if (newUser == null) {
          _showMessage('Unable to authenticate. Try restarting the app or check your internet connection.');
          return;
        }
        
        // Continue with the newly signed-in user
        return _processSendMessage(content, newUser.id);
      } catch (e) {
        AppLogger.error('Failed to sign in when trying to send message', e);
        _showMessage('Authentication failed. Please restart the app.');
        return;
      }
    }

    return _processSendMessage(content, user.id);
  }
  
  // Helper method to process the message sending after authentication check
  Future<void> _processSendMessage(String content, String userId) async {
    // Rate limit check
    if (_lastMessageSentTime != null) {
      final Duration elapsed = DateTime.now().difference(_lastMessageSentTime!);
      if (elapsed.inMinutes < MessageService.messageCooldownMinutes) {
        final int remainingSeconds = (MessageService.messageCooldownMinutes * 60) - elapsed.inSeconds;
        _showMessage('Please wait $remainingSeconds seconds before sending another message.');
        return;
      }
    }

    AppLogger.info('Sending message as user: $userId');
    final success = await _messageService.sendMessage(
      content: content,
      userId: userId,
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
          // Offline indicator with reconnect button
          if (_isOffline)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Chip(
                    label: const Text('OFFLINE', 
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                    avatar: Icon(Icons.cloud_off, 
                      size: 16, 
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _tryReconnect,
                    tooltip: 'Try to reconnect',
                  ),
                ],
              ),
            ),
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
