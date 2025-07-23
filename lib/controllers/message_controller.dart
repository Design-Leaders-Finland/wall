import '../models/message.dart';
import '../services/message_service.dart';
import '../utils/logger.dart';

/// Controller for managing message operations and state
class MessageController {
  final MessageService _messageService = MessageService();

  List<Message> _messages = [];
  DateTime? _lastMessageSentTime;
  Function(List<Message>)? _onMessagesUpdated;

  /// Gets the current list of messages
  List<Message> get messages => _messages;

  /// Gets the last message sent time for rate limiting
  DateTime? get lastMessageSentTime => _lastMessageSentTime;

  /// Gets visible (non-expired) messages
  List<Message> get visibleMessages =>
      _messageService.getVisibleMessages(_messages);

  /// Checks if the service is online
  bool get isOnline => _messageService.isOnline;

  /// Sets callback for when messages are updated
  set onMessagesUpdated(Function(List<Message>)? callback) {
    _onMessagesUpdated = callback;
  }

  /// Initializes the message service and sets up real-time subscription
  void initialize() {
    // Setup message callback
    _messageService.onNewMessage = (newMessage) {
      _messages.add(newMessage);
      _sortMessages();
      _onMessagesUpdated?.call(_messages);
    };

    // Initialize realtime subscription
    _messageService.initRealtimeSubscription();
  }

  /// Fetches messages from the service
  Future<List<Message>> fetchMessages() async {
    final messages = await _messageService.fetchMessages();
    _messages = messages;
    _sortMessages();
    return messages;
  }

  /// Sends a message with the given content and user ID
  Future<bool> sendMessage({
    required String content,
    required String userId,
  }) async {
    // Rate limit check
    if (_lastMessageSentTime != null) {
      final Duration elapsed = DateTime.now().difference(_lastMessageSentTime!);
      if (elapsed.inMinutes < MessageService.messageCooldownMinutes) {
        final int remainingSeconds =
            (MessageService.messageCooldownMinutes * 60) - elapsed.inSeconds;
        throw RateLimitException(
          'Please wait $remainingSeconds seconds before sending another message.',
        );
      }
    }

    AppLogger.info('Sending message as user: $userId');
    final success = await _messageService.sendMessage(
      content: content,
      userId: userId,
      lastMessageSentTime: _lastMessageSentTime,
    );

    if (success) {
      _lastMessageSentTime = DateTime.now();
    }

    return success;
  }

  /// Attempts to reconnect to the server
  Future<bool> tryReconnect() async {
    try {
      return await _messageService.tryReconnect();
    } catch (e) {
      AppLogger.error('Error trying to reconnect', e);
      return false;
    }
  }

  /// Gets count of local messages from current user
  int getLocalMessageCount() {
    return _messages.where((m) => m.isFromCurrentUser).length;
  }

  /// Sorts messages by creation time
  void _sortMessages() {
    _messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Disposes of the message service
  void dispose() {
    _messageService.dispose();
  }
}

/// Exception thrown when rate limit is exceeded
class RateLimitException implements Exception {
  final String message;

  const RateLimitException(this.message);

  @override
  String toString() => message;
}
