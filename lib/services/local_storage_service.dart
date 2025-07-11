import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';
import '../utils/logger.dart';

class LocalStorageService {
  static const String _messagesKey = 'local_messages';
  
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
}
