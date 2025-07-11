import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../utils/logger.dart';

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
    _messagesChannel = _supabaseClient
        .channel('public:$tableName')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: tableName,
          callback: (payload) {
            final newMessage = Message.fromJson(payload.newRecord);
            if (onNewMessage != null) {
              onNewMessage!(newMessage);
            }
          },
        )
        .subscribe();
  }
  
  // Dispose/unsubscribe from realtime updates
  void dispose() {
    _messagesChannel.unsubscribe();
  }
  
  // Fetch all messages
  Future<List<Message>> fetchMessages() async {
    try {
      final data = await _supabaseClient
          .from(tableName)
          .select('*')
          .order('created_at', ascending: true);
          
      return data.map<Message>((json) => Message.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching messages', e);
      return [];
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
    
    try {
      // Create the message
      final message = Message(
        content: content,
        userId: userId,
        createdAt: DateTime.now(),
      );
      
      // Insert into database
      await _supabaseClient.from(tableName).insert(message.toJson());
      return true;
    } catch (e) {
      AppLogger.error('Error sending message', e);
      return false;
    }
  }
  
  // Filter messages to only show those that are not expired
  List<Message> getVisibleMessages(List<Message> messages) {
    return messages.where((message) => !message.isExpired()).toList();
  }
}
