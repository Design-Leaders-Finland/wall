import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../utils/logger.dart';

class LocalStorageService {
  static const String _messagesKey = 'local_messages';
  static const String _currentUserMessagesKey = 'current_user_messages';
  
  // Save messages to local storage
  static Future<bool> saveMessages(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((message) => message.toJson()).toList();
      final jsonString = jsonEncode(messagesJson);
      
      await prefs.setString(_messagesKey, jsonString);
      AppLogger.info('Saved ${messages.length} messages to local storage');
      return true;
    } catch (e) {
      AppLogger.error('Error saving messages to local storage', e);
      return false;
    }
  }
  
  // Load messages from local storage
  static Future<List<Message>> loadMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_messagesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        AppLogger.info('No messages found in local storage');
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      final messages = jsonList.map((item) => Message.fromJson(item)).toList();
      AppLogger.info('Loaded ${messages.length} messages from local storage');
      return messages;
    } catch (e) {
      AppLogger.error('Error loading messages from local storage', e);
      return [];
    }
  }
  
  // Add a single message to local storage
  static Future<bool> addMessage(Message message) async {
    try {
      final messages = await loadMessages();
      messages.add(message);
      return await saveMessages(messages);
    } catch (e) {
      AppLogger.error('Error adding message to local storage', e);
      return false;
    }
  }
  
  // Clear all messages from local storage
  static Future<bool> clearMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_messagesKey);
      AppLogger.info('Cleared all messages from local storage');
      return true;
    } catch (e) {
      AppLogger.error('Error clearing messages from local storage', e);
      return false;
    }
  }
  
  // Save current user's messages to local storage
  static Future<bool> saveCurrentUserMessages(List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = messages.map((message) {
        // Mark all messages as being from the current user
        final messageMap = message.toJson();
        messageMap['is_from_current_user'] = true;
        return messageMap;
      }).toList();
      final jsonString = jsonEncode(messagesJson);
      
      await prefs.setString(_currentUserMessagesKey, jsonString);
      AppLogger.info('Saved ${messages.length} current user messages to local storage');
      return true;
    } catch (e) {
      AppLogger.error('Error saving current user messages to local storage', e);
      return false;
    }
  }
  
  // Load current user's messages from local storage
  static Future<List<Message>> loadCurrentUserMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_currentUserMessagesKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        AppLogger.info('No current user messages found in local storage');
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      final messages = jsonList.map((item) {
        // Ensure they're marked as current user messages
        final messageMap = Map<String, dynamic>.from(item);
        messageMap['is_from_current_user'] = true;
        return Message.fromJson(messageMap);
      }).toList();
      
      AppLogger.info('Loaded ${messages.length} current user messages from local storage');
      return messages;
    } catch (e) {
      AppLogger.error('Error loading current user messages from local storage', e);
      return [];
    }
  }
  
  // Add a message from the current user to local storage
  static Future<bool> addCurrentUserMessage(Message message) async {
    try {
      final messages = await loadCurrentUserMessages();
      // Ensure it's marked as from current user
      final userMessage = Message(
        content: message.content,
        userId: message.userId,
        createdAt: message.createdAt,
        isFromCurrentUser: true,
      );
      messages.add(userMessage);
      return await saveCurrentUserMessages(messages);
    } catch (e) {
      AppLogger.error('Error adding current user message to local storage', e);
      return false;
    }
  }
  
  // Clear current user's messages from local storage
  static Future<bool> clearCurrentUserMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserMessagesKey);
      AppLogger.info('Cleared all current user messages from local storage');
      return true;
    } catch (e) {
      AppLogger.error('Error clearing current user messages from local storage', e);
      return false;
    }
  }
  
  // Load all messages including both remote and current user messages
  static Future<List<Message>> loadAllMessages() async {
    final remoteMessages = await loadMessages();
    final userMessages = await loadCurrentUserMessages();
    
    // Combine both lists
    final allMessages = [...remoteMessages, ...userMessages];
    
    // Sort by creation time
    allMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    
    return allMessages;
  }
}
