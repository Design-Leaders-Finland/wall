import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // For formatting dates

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  late final RealtimeChannel _messagesChannel;
  DateTime? _lastMessageSentTime; // To track the last message sent by this user

  static const int _messageMaxLength = 160; // Max message length
  static const int _messageCooldownMinutes = 1; // Cooldown period in minutes

  @override
  void initState() {
    super.initState();
    _signInAndListen();
  }

  Future<void> _signInAndListen() async {
    // Ensure user is signed in anonymously first
    await Supabase.instance.client.auth.signInAnonymously();

    // Fetch initial messages
    await _fetchMessages();

    // Set up real-time listener for new messages
    _messagesChannel = Supabase.instance.client
        .channel('public:messages')
        .on(
          RealtimeListenTypes.postgresChanges,
          ChannelFilter(event: 'INSERT', schema: 'public', table: 'messages'),
          (payload, [ref]) {
            final newMessage = payload['new'] as Map<String, dynamic>;
            setState(() {
              _messages.add(newMessage);
              _sortMessages();
            });
          },
        )
        .subscribe();
  }
  // In your home_page.dart or a special auth file
Future<void> signInAnonymously() async {
  try {
    await Supabase.instance.client.auth.signInAnonymously();
    print('Signed in anonymously!'); // Hooray!
  } on AuthException catch (e) {
    print('Oops, error signing in: ${e.message}');
  } catch (e) {
    print('Something unexpected happened: $e');
  }
}

  Future<void> _fetchMessages() async {
    try {
      final data = await Supabase.instance.client
          .from('messages')
          .select('*')
          .order('created_at', ascending: true); // Sort by creation time

      setState(() {
        _messages = List<Map<String, dynamic>>.from(data);
        _sortMessages();
      });
    } catch (e) {
      print('Error fetching messages: $e');
    }
  }

  void _sortMessages() {
    _messages.sort((a, b) {
      final DateTime timeA = DateTime.parse(a['created_at']);
      final DateTime timeB = DateTime.parse(b['created_at']);
      return timeA.compareTo(timeB);
    });
  }

  Future<void> _sendMessage() async {
    final String messageContent = _messageController.text.trim();

    if (messageContent.isEmpty) {
      _showMessage('Message cannot be empty.');
      return;
    }

    if (messageContent.length > _messageMaxLength) {
      _showMessage('Message exceeds $_messageMaxLength characters.');
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _showMessage('User not authenticated. Please restart the app.');
      return;
    }

    // Check for rate limiting
    if (_lastMessageSentTime != null) {
      final Duration elapsed = DateTime.now().difference(_lastMessageSentTime!);
      if (elapsed.inMinutes < _messageCooldownMinutes) {
        final int remainingSeconds = (_messageCooldownMinutes * 60) - elapsed.inSeconds;
        _showMessage('Please wait $remainingSeconds seconds before sending another message.');
        return;
      }
    }

    try {
      await Supabase.instance.client.from('messages').insert({
        'content': messageContent,
        'user_id': user.id,
        'created_at': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
      setState(() {
        _lastMessageSentTime = DateTime.now(); // Update last sent time on success
      });
    } catch (e) {
      _showMessage('Error sending message: $e');
      print('Error sending message: $e'); // Log for debugging
    }
  }

  // Helper to show a temporary message to the user
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Message expiration logic
  List<Map<String, dynamic>> _getVisibleMessages() {
    final now = DateTime.now();
    return _messages.where((message) {
      final createdAt = DateTime.parse(message['created_at']);
      return now.difference(createdAt).inMinutes < 5;
    }).toList();
  }

  @override
  void dispose() {
    _messagesChannel.unsubscribe();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleMessages = _getVisibleMessages(); // Filter messages for display

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ephemeral Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // Show latest messages at the bottom
              itemCount: visibleMessages.length,
              itemBuilder: (context, index) {
                final message = visibleMessages[visibleMessages.length - 1 - index]; // Display in correct order
                final createdAt = DateTime.parse(message['created_at']);
                final formattedTime = DateFormat('HH:mm').format(createdAt.toLocal());
                return ListTile(
                  title: Text(message['content']),
                  subtitle: Text('$formattedTime - ${message['user_id']?.substring(0, 8) ?? 'Anon'}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    maxLength: _messageMaxLength, // Enforce max length in UI
                    decoration: const InputDecoration(
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                      counterText: '', // Hide default character counter
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
