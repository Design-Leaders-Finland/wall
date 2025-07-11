import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../utils/logger.dart';
import 'local_storage_service.dart';

class MessageService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  late final RealtimeChannel _messagesChannel;
  
  // Callback for new messages
  Function(Message)? onNewMessage;
  
  // Message constraints
  static const int messageMaxLength = 160;
  static const int messageCooldownMinutes = 1;
  static const String tableName = 'messages';
  
  // Initialize realtime subscription
  void initRealtimeSubscription() {
    try {
      AppLogger.info('Initializing realtime subscription for messages');
      _messagesChannel = _supabaseClient
          .channel('public:$tableName')
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: tableName,
            callback: (payload) {
              final newMessage = Message.fromJson(payload.newRecord);
              AppLogger.info('New message received from user: ${newMessage.userId}');
              
              // Save message to local storage for offline access
              LocalStorageService.addMessage(newMessage).then((success) {
                if (!success) {
                  AppLogger.warning('Failed to save received message to local storage');
                }
              });
              
              if (onNewMessage != null) {
                onNewMessage!(newMessage);
              }
            },
          )
          .subscribe();
      _isOnline = true;
      AppLogger.info('Realtime subscription initialized successfully');
    } catch (e) {
      AppLogger.error('Error initializing realtime subscription', e);
      _isOnline = false;
      // Don't rethrow - we want to gracefully handle this error
    }
  }
  
  // Try to reconnect if we're offline
  Future<bool> tryReconnect() async {
    if (_isOnline) return true;
    
    try {
      // Test connection by making a small request
      await _supabaseClient.from(tableName).select('count').limit(1);
      _isOnline = true;
      
      // Re-initialize subscription
      initRealtimeSubscription();
      return true;
    } catch (e) {
      AppLogger.warning('Reconnection attempt failed: ${e.toString()}');
      return false;
    }
  }
  
  // Dispose/unsubscribe from realtime updates
  void dispose() {
    _messagesChannel.unsubscribe();
  }
  
  // Track connectivity state
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  // Fetch all messages
  Future<List<Message>> fetchMessages() async {
    try {
      AppLogger.info('Attempting to fetch messages from Supabase');
      final data = await _supabaseClient
          .from(tableName)
          .select('*')
          .order('created_at', ascending: true);
      
      final messages = data.map<Message>((json) => Message.fromJson(json)).toList();
      AppLogger.info('Successfully fetched ${messages.length} messages from Supabase');
      
      // We successfully connected, so save these messages locally too
      _isOnline = true;
      await LocalStorageService.saveMessages(messages);
      
      return messages;
    } catch (e) {
      AppLogger.error('Error fetching messages from Supabase', e);
      _isOnline = false;
      
      // Check if the error is related to authentication or connectivity
      if (e.toString().contains('JWT') || e.toString().contains('authentication') || 
          e.toString().contains('auth') || e.toString().contains('permission') ||
          e.toString().contains('network') || e.toString().contains('connect')) {
        AppLogger.warning('Authentication/connectivity issue. Falling back to local storage.');
      }
      
      // Fall back to local storage
      final localMessages = await LocalStorageService.loadMessages();
      AppLogger.info('Loaded ${localMessages.length} messages from local storage');
      return localMessages;
    }
  }
  
  // Send a new message
  Future<bool> sendMessage({
    required String content, 
    required String userId,
    DateTime? lastMessageSentTime,
  }) async {
    // Validate content
    if (content.isEmpty) {
      return false;
    }
    
    if (content.length > messageMaxLength) {
      return false;
    }
    
    // Rate limiting check
    if (lastMessageSentTime != null) {
      final Duration elapsed = DateTime.now().difference(lastMessageSentTime);
      if (elapsed.inMinutes < messageCooldownMinutes) {
        return false;
      }
    }
    
    // Create the message
    final message = Message(
      content: content,
      userId: userId,
      createdAt: DateTime.now(),
    );
    
    try {
      if (_isOnline) {
        // Try to insert into database
        await _supabaseClient.from(tableName).insert(message.toJson());
        
        // Save locally as well for offline access
        await LocalStorageService.addMessage(message);
        
        AppLogger.info('Message sent and stored both remotely and locally');
        return true;
      } else {
        // If we know we're offline, just store locally
        AppLogger.info('Offline mode: Storing message locally only');
        final success = await LocalStorageService.addMessage(message);
        
        // If local storage succeeds, trigger the message callback
        if (success && onNewMessage != null) {
          onNewMessage!(message);
        }
        
        return success;
      }
    } catch (e) {
      AppLogger.error('Error sending message to Supabase', e);
      
      // If remote storage fails, try local storage as fallback
      _isOnline = false;
      AppLogger.info('Falling back to local storage for message');
      final success = await LocalStorageService.addMessage(message);
      
      // If local storage succeeds, trigger the message callback
      if (success && onNewMessage != null) {
        onNewMessage!(message);
      }
      
      return success;
    }
  }
  
  // Filter messages to only show those that are not expired
  List<Message> getVisibleMessages(List<Message> messages) {
    return messages.where((message) => !message.isExpired()).toList();
  }
}
