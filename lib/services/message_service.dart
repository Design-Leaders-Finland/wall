/// A service for managing real-time messaging functionality.
///
/// This service handles message storage, retrieval, real-time subscriptions,
/// and offline synchronization with Supabase backend. It provides both
/// online and offline capabilities with automatic fallback mechanisms.
///
/// ## Features
/// - Real-time message synchronization via Supabase Realtime
/// - Offline message storage and retrieval
/// - Automatic polling fallback when realtime is unavailable
/// - Message validation and rate limiting
/// - Guest user support with local-only storage
///
/// ## Usage
/// ```dart
/// final messageService = MessageService();
///
/// // Initialize real-time subscription
/// messageService.initRealtimeSubscription();
///
/// // Send a message
/// final success = await messageService.sendMessage(
///   content: 'Hello world!',
///   userId: 'user123',
/// );
///
/// // Fetch all messages
/// final messages = await messageService.fetchMessages();
///
/// // Clean up when done
/// messageService.dispose();
/// ```
library;

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message.dart';
import '../utils/logger.dart';
import 'local_storage_service.dart';
import 'auth_service.dart';

class MessageService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final AuthService _authService = AuthService();
  late final RealtimeChannel _messagesChannel;

  /// Callback function that gets triggered when a new message is received.
  ///
  /// This callback is invoked both for messages received via real-time
  /// subscription and for locally sent messages when offline.
  Function(Message)? onNewMessage;

  /// Maximum allowed length for message content in characters.
  ///
  /// Messages exceeding this length will be rejected by [sendMessage].
  static const int messageMaxLength = 160;

  /// Minimum time interval between messages from the same user in minutes.
  ///
  /// Used for rate limiting to prevent spam. Messages sent within this
  /// interval will be rejected by [sendMessage].
  static const int messageCooldownMinutes = 1;

  /// Name of the Supabase table used for message storage.
  static const String tableName = 'messages';

  /// Initializes real-time subscription for message updates.
  ///
  /// Sets up a Supabase Realtime channel to listen for new messages.
  /// If realtime is not enabled or fails, automatically falls back to
  /// polling mode for message updates.
  ///
  /// The subscription will:
  /// - Listen for INSERT events on the messages table
  /// - Automatically save received messages to local storage
  /// - Trigger the [onNewMessage] callback for new messages
  /// - Handle connection errors gracefully
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
                var newMessage = Message.fromJson(payload.newRecord);

                // Generate display name if not present and not from current user
                if (newMessage.displayName == null &&
                    !newMessage.isFromCurrentUser) {
                  // Generate a display name based on the message's user ID
                  final displayName = _generateDisplayNameForUser(
                    newMessage.userId,
                  );

                  // Create a new message with the display name
                  newMessage = Message(
                    content: newMessage.content,
                    userId: newMessage.userId,
                    createdAt: newMessage.createdAt,
                    isFromCurrentUser: newMessage.isFromCurrentUser,
                    displayName: displayName,
                  );
                }

                AppLogger.info(
                  'New message received from user: ${newMessage.userId}',
                );

                // Save message to local storage for offline access
                LocalStorageService.addMessage(newMessage).then((success) {
                  if (!success) {
                    AppLogger.warning(
                      'Failed to save received message to local storage',
                    );
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
              AppLogger.error(
                'Realtime subscription error: ${error?.toString()}',
              );
              _isOnline = false;

              // Check if this is the specific Realtime not enabled error
              if (error?.toString().contains(
                        'Unable to subscribe to changes',
                      ) ==
                      true ||
                  error?.toString().contains('Realtime is not enabled') ==
                      true) {
                AppLogger.warning(
                  'Realtime is not enabled for the messages table. App will work in polling mode.',
                );
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
      AppLogger.warning(
        'Error unsubscribing from realtime channel: ${e.toString()}',
      );
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
    _pollingTimer = Stream.periodic(const Duration(seconds: 30)).listen((
      _,
    ) async {
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

      final messages = data.map<Message>((json) {
        var message = Message.fromJson(json);

        // Add display name if not present and not from current user
        if (message.displayName == null && !message.isFromCurrentUser) {
          final displayName = _generateDisplayNameForUser(message.userId);
          message = Message(
            content: message.content,
            userId: message.userId,
            createdAt: message.createdAt,
            isFromCurrentUser: message.isFromCurrentUser,
            displayName: displayName,
          );
        }

        return message;
      }).toList();
      AppLogger.info(
        'Successfully fetched ${messages.length} messages from Supabase',
      );

      // We successfully connected, so save these messages locally too
      _isOnline = true;
      await LocalStorageService.saveMessages(messages);

      // Also get current user's messages and combine them
      final currentUserMessages =
          await LocalStorageService.loadCurrentUserMessages();
      final allMessages = [...messages, ...currentUserMessages];

      // Sort by creation time
      allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      return allMessages;
    } catch (e) {
      AppLogger.error('Error fetching messages from Supabase', e);
      _isOnline = false;

      // Check if the error is related to authentication or connectivity
      if (e.toString().contains('JWT') ||
          e.toString().contains('authentication') ||
          e.toString().contains('auth') ||
          e.toString().contains('permission') ||
          e.toString().contains('network') ||
          e.toString().contains('connect')) {
        AppLogger.warning(
          'Authentication/connectivity issue. Falling back to local storage.',
        );
      }

      // Fall back to local storage - load both regular cached messages and current user's messages
      final allMessages = await LocalStorageService.loadAllMessages();
      AppLogger.info(
        'Loaded ${allMessages.length} messages from local storage (including user messages)',
      );
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
    final displayName = _authService.getHumanReadableName();
    final message = Message(
      content: content,
      userId: userId,
      createdAt: DateTime.now(),
      isFromCurrentUser: true, // Mark as from current user
      displayName: displayName, // Add human-readable display name
    );

    try {
      // Check if user is a guest user (UUID starting with 00000000-0000-4000-8000)
      final isGuestUser = userId.startsWith('00000000-0000-4000-8000');

      if (_isOnline) {
        // Try to insert into database for both authenticated and guest users
        // Guest users can send messages to the database in an anonymous chat wall
        final messageToSend = {
          'content': message.content,
          'user_id': message.userId,
          'created_at': message.createdAt.toIso8601String(),
          // Don't send isFromCurrentUser to the server
        };

        AppLogger.info(
          'Attempting to send message to Supabase: ${isGuestUser ? "Guest user" : "Authenticated user"}',
        );

        await _supabaseClient.from(tableName).insert(messageToSend);

        // Save locally as well for offline access, marked as current user's message
        await LocalStorageService.addCurrentUserMessage(message);

        AppLogger.info('Message sent and stored both remotely and locally');
        return true;
      } else {
        // When offline, store locally only
        AppLogger.info('Offline mode: Storing message locally only');

        final success = await LocalStorageService.addCurrentUserMessage(
          message,
        );

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
    return messages
        .where((message) => !message.isExpired() || message.isFromCurrentUser)
        .toList();
  }

  // Generate a human-readable display name for a given user ID
  String _generateDisplayNameForUser(String userId) {
    try {
      // Split UUID into 4 parts (separated by hyphens)
      final uuidParts = userId.split('-');
      if (uuidParts.length != 5) {
        throw Exception('Invalid UUID format');
      }

      // Use the first 4 parts of UUID (ignore the last part for now)
      final part1 = uuidParts[0];
      final part2 = uuidParts[1];
      final part3 = uuidParts[2];
      final part4 = uuidParts[3];

      // Convert each UUID part to a word using consistent vocabulary
      final word1 = _getWordFromUuidPart(part1, _adjectives);
      final word2 = _getWordFromUuidPart(part2, _colors);
      final word3 = _getWordFromUuidPart(part3, _animals);
      final word4 = _getWordFromUuidPart(part4, _objects);

      return '$word1 $word2 $word3 $word4';
    } catch (e) {
      AppLogger.error('Failed to generate display name for user: $userId', e);
      // Fallback to a simple format using the last part of UUID
      final shortId = userId.split('-').last.substring(0, 6);
      return 'Guest-$shortId';
    }
  }

  // Convert a UUID part (hex string) to an index for word selection
  String _getWordFromUuidPart(String uuidPart, List<String> vocabulary) {
    // Convert hex string to integer and use modulo to get index
    final hexValue = int.parse(uuidPart, radix: 16);
    final index = hexValue % vocabulary.length;
    return vocabulary[index];
  }

  // Vocabulary lists for consistent word generation
  static const List<String> _adjectives = [
    'Swift',
    'Bright',
    'Calm',
    'Bold',
    'Wise',
    'Kind',
    'Quick',
    'Strong',
    'Gentle',
    'Brave',
    'Sharp',
    'Clear',
    'Warm',
    'Cool',
    'Fast',
    'Smooth',
    'Steady',
    'Happy',
    'Smart',
    'Fresh',
    'Pure',
    'Noble',
    'Fine',
    'True',
    'Grand',
    'Fair',
    'Rich',
    'Deep',
    'High',
    'Wide',
    'Soft',
    'Hard',
  ];

  static const List<String> _colors = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Purple',
    'Pink',
    'Brown',
    'Black',
    'White',
    'Gray',
    'Silver',
    'Gold',
    'Cyan',
    'Magenta',
    'Lime',
    'Navy',
    'Teal',
    'Olive',
    'Maroon',
    'Coral',
    'Salmon',
    'Violet',
    'Indigo',
    'Crimson',
    'Azure',
    'Jade',
    'Ruby',
    'Amber',
    'Pearl',
    'Ivory',
    'Bronze',
  ];

  static const List<String> _animals = [
    'Lion',
    'Tiger',
    'Bear',
    'Wolf',
    'Fox',
    'Eagle',
    'Hawk',
    'Owl',
    'Dolphin',
    'Whale',
    'Shark',
    'Horse',
    'Deer',
    'Rabbit',
    'Turtle',
    'Frog',
    'Butterfly',
    'Bee',
    'Ant',
    'Spider',
    'Cat',
    'Dog',
    'Bird',
    'Fish',
    'Snake',
    'Lizard',
    'Mouse',
    'Rat',
    'Bat',
    'Seal',
    'Penguin',
    'Kangaroo',
  ];

  static const List<String> _objects = [
    'Star',
    'Moon',
    'Sun',
    'Cloud',
    'Mountain',
    'River',
    'Ocean',
    'Forest',
    'Stone',
    'Crystal',
    'Diamond',
    'Pearl',
    'Flame',
    'Wind',
    'Thunder',
    'Rain',
    'Snow',
    'Ice',
    'Fire',
    'Earth',
    'Sky',
    'Wave',
    'Rock',
    'Tree',
    'Flower',
    'Leaf',
    'Seed',
    'Root',
    'Branch',
    'Light',
    'Shadow',
    'Dream',
  ];
}
