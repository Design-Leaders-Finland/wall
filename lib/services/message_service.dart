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
              try {
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
              } catch (e) {
                AppLogger.error('Error processing realtime message', e);
              }
            },
          )
          .subscribe((status, [error]) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              AppLogger.info('Realtime subscription successful');
              _isOnline = true;
            } else if (status == RealtimeSubscribeStatus.closed) {
              AppLogger.warning('Realtime subscription closed');
              _isOnline = false;
            } else if (status == RealtimeSubscribeStatus.channelError) {
              AppLogger.error('Realtime subscription error: ${error?.toString()}');
              _isOnline = false;
              
              // Check if this is the specific Realtime not enabled error
              if (error?.toString().contains('Unable to subscribe to changes') == true ||
                  error?.toString().contains('Realtime is not enabled') == true) {
                AppLogger.warning('Realtime is not enabled for the messages table. App will work in polling mode.');
                // Set up polling fallback (optional)
                _setupPollingFallback();
              }
            }
          });
      
      AppLogger.info('Realtime subscription setup initiated');
    } catch (e) {
      AppLogger.error('Error setting up realtime subscription', e);
      _isOnline = false;
      _setupPollingFallback();
    }
  }
  
  // Try to reconnect if we're offline
  Future<bool> tryReconnect() async {
    if (_isOnline) return true;
    
    try {
      // Test connection by making a small request
      await _supabaseClient.from(tableName).select('count').limit(1);
      _isOnline = true;
      
      // Cancel polling if it's running
      _pollingTimer?.cancel();
      _pollingTimer = null;
      
      // Re-initialize subscription
      initRealtimeSubscription();
      return true;
    } catch (e) {
      AppLogger.warning('Reconnection attempt failed: ${e.toString()}');
      // If reconnection fails, continue with polling fallback
      if (_pollingTimer == null) {
        _setupPollingFallback();
      }
      return false;
    }
  }
  
  // Dispose/unsubscribe from realtime updates
  void dispose() {
    try {
      _messagesChannel.unsubscribe();
    } catch (e) {
      AppLogger.warning('Error unsubscribing from realtime channel: ${e.toString()}');
    }
    
    // Cancel polling timer if it exists
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
  
  // Track connectivity state
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  // Polling timer for fallback when realtime is not available
  dynamic _pollingTimer;
  
  // Setup polling fallback when realtime is not available
  void _setupPollingFallback() {
    AppLogger.info('Setting up polling fallback for message updates');
    // Cancel any existing timer
    _pollingTimer?.cancel();
    
    // Poll every 30 seconds for new messages
    _pollingTimer = Stream.periodic(const Duration(seconds: 30))
        .listen((_) async {
      try {
        final messages = await fetchMessages();
        // This will trigger UI updates through the normal flow
        AppLogger.info('Polling: fetched ${messages.length} messages');
      } catch (e) {
        AppLogger.warning('Polling failed: ${e.toString()}');
      }
    });
  }

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
      
      // Also get current user's messages and combine them
      final currentUserMessages = await LocalStorageService.loadCurrentUserMessages();
      final allMessages = [...messages, ...currentUserMessages];
      
      // Sort by creation time
      allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      
      return allMessages;
    } catch (e) {
      AppLogger.error('Error fetching messages from Supabase', e);
      _isOnline = false;
      
      // Check if the error is related to authentication or connectivity
      if (e.toString().contains('JWT') || e.toString().contains('authentication') || 
          e.toString().contains('auth') || e.toString().contains('permission') ||
          e.toString().contains('network') || e.toString().contains('connect')) {
        AppLogger.warning('Authentication/connectivity issue. Falling back to local storage.');
      }
      
      // Fall back to local storage - load both regular cached messages and current user's messages
      final allMessages = await LocalStorageService.loadAllMessages();
      AppLogger.info('Loaded ${allMessages.length} messages from local storage (including user messages)');
      return allMessages;
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
      isFromCurrentUser: true, // Mark as from current user
    );
    
    try {
      if (_isOnline) {
        // Try to insert into database
        final messageToSend = {
          'content': message.content,
          'user_id': message.userId,
          'created_at': message.createdAt.toIso8601String(),
          // Don't send isFromCurrentUser to the server
        };
        
        await _supabaseClient.from(tableName).insert(messageToSend);
        
        // Save locally as well for offline access, marked as current user's message
        await LocalStorageService.addCurrentUserMessage(message);
        
        AppLogger.info('Message sent and stored both remotely and locally');
        return true;
      } else {
        // If we know we're offline, just store locally as current user's message
        AppLogger.info('Offline mode: Storing message locally only');
        final success = await LocalStorageService.addCurrentUserMessage(message);
        
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
      final success = await LocalStorageService.addCurrentUserMessage(message);
      
      // If local storage succeeds, trigger the message callback
      if (success && onNewMessage != null) {
        onNewMessage!(message);
      }
      
      return success;
    }
  }
  
  // Filter messages to only show those that are not expired
  // (always show current user's messages even if expired)
  List<Message> getVisibleMessages(List<Message> messages) {
    return messages.where((message) => 
      !message.isExpired() || message.isFromCurrentUser
    ).toList();
  }
}
