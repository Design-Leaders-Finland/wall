// Main home page for the Wall application
// Manages real-time messaging functionality, user authentication, and connection status
import 'package:flutter/material.dart';
import 'models/message.dart';
import 'controllers/auth_controller.dart';
import 'controllers/message_controller.dart';
import 'controllers/connection_manager.dart';
import 'controllers/home_page_state.dart';
import 'exceptions/auth_exception.dart';
import 'utils/logger.dart';
import 'widgets/message_input.dart';
import 'widgets/message_list.dart';
import 'widgets/auth_error_widget.dart';
import 'widgets/offline_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthController _authController = AuthController();
  final MessageController _messageController = MessageController();
  final ConnectionManager _connectionManager = ConnectionManager();
  final HomePageState _pageState = HomePageState();

  @override
  void initState() {
    super.initState();
    _messageController.onMessagesUpdated = (messages) {
      setState(() {
        final localMessages = messages
            .where((m) => m.isFromCurrentUser)
            .toList();
        _connectionManager.updateConnectionState(
          isOffline: !_messageController.isOnline,
          localMessageCount: localMessages.length,
        );
      });
    };
    _initialize();
  }

  Future<void> _initialize() async {
    _pageState.reset();
    setState(() {});

    try {
      // Attempt authentication (may fall back to guest mode)
      final user = await _authController.signInAnonymously();

      if (user == null) {
        _showMessage(
          'Running in guest mode. Your messages are stored locally.',
        );
      }

      // Initialize message controller
      _messageController.initialize();

      // Fetch initial messages
      await _fetchMessages();

      _pageState.setInitialized();
      _connectionManager.updateConnectionState(
        isOffline: !_messageController.isOnline,
      );
      setState(() {});

      if (_connectionManager.isOffline && user != null) {
        _showMessage('Working in offline mode. Messages are stored locally.');
      }
    } on AuthFailedException catch (e) {
      AppLogger.error('Authentication exception caught in HomePage', e);

      // Try to continue in read-only mode despite auth failure
      try {
        // Initialize message controller anyway
        _messageController.initialize();

        // Fetch initial messages - will use local storage if online fetch fails
        await _fetchMessages();

        _pageState.setInitialized();
        _connectionManager.setOfflineMode(
          _messageController.getLocalMessageCount(),
        );
        setState(() {});

        _showMessage(
          'Authentication failed. Working in offline mode with local data.',
        );
      } catch (innerError) {
        // Only if both auth and data fetching fail, show the error screen
        _pageState.setAuthFailed(true, e.toString());
        setState(() {});
      }
    } catch (e) {
      AppLogger.error('Unexpected error during initialization', e);

      // Try to fetch local messages even if initialization failed
      try {
        await _fetchMessages();

        _pageState.setInitialized();
        _connectionManager.setOfflineMode(
          _messageController.getLocalMessageCount(),
        );
        setState(() {});

        _showMessage(
          'Connection error. Working in offline mode with local data.',
        );
      } catch (localError) {
        // If even local storage fails, show the error screen
        _pageState.setAuthFailed(
          true,
          'Error during initialization: ${e.toString()}',
        );
        setState(() {});
      }
    }
  }

  Future<void> _fetchMessages() async {
    final messages = await _messageController.fetchMessages();
    final localMessages = messages.where((m) => m.isFromCurrentUser).toList();

    setState(() {
      _connectionManager.updateConnectionState(
        isOffline: !_messageController.isOnline,
        localMessageCount: localMessages.length,
      );
    });
  }

  // Try to reconnect to the server
  Future<void> _tryReconnect() async {
    if (!_connectionManager.isOffline) return;

    _pageState.setLoading(true);
    setState(() {});

    try {
      final success = await _messageController.tryReconnect();
      if (success) {
        await _fetchMessages();
        _showMessage(
          'Reconnected successfully. Your local messages will sync when you send a new message.',
        );
      } else {
        _showMessage('Still offline. Your messages are saved locally.');
      }
    } catch (e) {
      AppLogger.error('Error trying to reconnect', e);
      _showMessage('Failed to reconnect. Still in offline mode.');
    } finally {
      _pageState.setLoading(false);
      setState(() {});
    }
  }

  Future<void> _handleSendMessage(String content) async {
    final (userId, isGuest) = _authController.getUserIdForMessaging();
    return _processSendMessage(content, userId);
  }

  // Helper method to process the message sending after authentication check
  Future<void> _processSendMessage(String content, String userId) async {
    try {
      final success = await _messageController.sendMessage(
        content: content,
        userId: userId,
      );

      if (success) {
        // If we're offline, we need to refresh the messages list explicitly
        // since the realtime subscription won't work
        if (_connectionManager.isOffline) {
          await _fetchMessages();
        }
      } else {
        _showMessage('Failed to send message. Please try again.');
      }
    } on RateLimitException catch (e) {
      _showMessage(e.message);
    } catch (e) {
      AppLogger.error('Error sending message', e);
      _showMessage('Failed to send message. Please try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter to only visible messages (not expired)
    final visibleMessages = _messageController.visibleMessages;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WALL',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        actions: [
          // Offline indicator with reconnect button
          if (_connectionManager.isOffline)
            OfflineIndicator(
              displayText: _connectionManager.getOfflineDisplayText(),
              onReconnect: _tryReconnect,
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
    if (_pageState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show auth error UI
    if (_pageState.authFailed) {
      return AuthErrorWidget(
        errorMessage: _pageState.authErrorMessage,
        onRetry: _initialize,
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
        Expanded(child: MessageList(messages: visibleMessages)),
        // Message input at bottom
        MessageInput(onSendMessage: _handleSendMessage),
      ],
    );
  }
}
