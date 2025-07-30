// Main home page for the Wall application
// Manages real-time messaging functionality, user authentication, and connection status
import 'package:flutter/material.dart';
import 'models/message.dart';
import 'controllers/auth_controller.dart';
import 'controllers/message_controller.dart';
import 'controllers/connection_manager.dart';
import 'controllers/home_page_state.dart';
import 'services/message_service.dart';
import 'exceptions/auth_exception.dart';
import 'utils/logger.dart';
import 'widgets/message_input.dart';
import 'widgets/message_list.dart';
import 'widgets/auth_error_widget.dart';
import 'widgets/offline_indicator.dart';
import 'widgets/cooldown_timer.dart';

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
        _connectionManager.updateConnectionState(
          isOffline: !_messageController.isOnline,
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
        _showMessage('Working in offline mode.');
      }
    } on AuthFailedException catch (e) {
      AppLogger.error('Authentication exception caught in HomePage', e);

      // Try to continue in read-only mode despite auth failure
      try {
        // Initialize message controller anyway
        _messageController.initialize();

        // Fetch initial messages
        await _fetchMessages();

        _pageState.setInitialized();
        _connectionManager.setOfflineMode(0);
        setState(() {});

        _showMessage('Authentication failed. Working in offline mode.');
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
        _connectionManager.setOfflineMode(0);
        setState(() {});

        _showMessage('Connection error. Working in offline mode.');
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
    await _messageController.fetchMessages();

    setState(() {
      _connectionManager.updateConnectionState(
        isOffline: !_messageController.isOnline,
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
        _showMessage('Reconnected successfully.');
      } else {
        _showMessage('Still offline.');
      }
    } catch (e) {
      AppLogger.error('Error trying to reconnect', e);
      _showMessage('Failed to reconnect. Still in offline mode.');
    } finally {
      _pageState.setLoading(false);
      setState(() {});
    }
  }

  Future<bool> _handleSendMessage(String content) async {
    final (userId, isGuest) = _authController.getUserIdForMessaging();
    return _processSendMessage(content, userId);
  }

  // Helper method to process the message sending after authentication check
  Future<bool> _processSendMessage(String content, String userId) async {
    try {
      final success = await _messageController.sendMessage(
        content: content,
        userId: userId,
      );

      if (success) {
        // Message sent successfully
        return true;
      } else {
        _showMessage('Failed to send message. Please try again.');
        return false;
      }
    } on RateLimitException catch (e) {
      _showMessage(e.message);
      return false;
    } catch (e) {
      AppLogger.error('Error sending message', e);
      _showMessage('Failed to send message. Please try again.');
      return false;
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// Checks if the user is currently in the message sending cooldown period.
  /// Returns true if less than [MessageService.messageCooldownMinutes] have
  /// passed since the last message was sent.
  bool _isInCooldown() {
    final lastMessageTime = _messageController.lastMessageSentTime;
    if (lastMessageTime == null) return false;

    final elapsed = DateTime.now().difference(lastMessageTime);
    return elapsed.inMinutes < MessageService.messageCooldownMinutes;
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
        // Cooldown timer (shown when rate limited)
        if (_messageController.lastMessageSentTime != null && _isInCooldown())
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: CooldownTimer(
              lastMessageTime: _messageController.lastMessageSentTime!,
              onCooldownExpired: () {
                setState(() {
                  // Refresh UI when cooldown expires
                });
              },
            ),
          ),
        // Message input at bottom
        MessageInput(
          onSendMessage: _handleSendMessage,
          isInCooldown: _isInCooldown(),
        ),
      ],
    );
  }
}
