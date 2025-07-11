import 'package:intl/intl.dart';

class Message {
  final String content;
  final String userId;
  final DateTime createdAt;
  
  Message({
    required this.content, 
    required this.userId, 
    required this.createdAt
  });
  
  // Create from JSON (Map)
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      content: json['content'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
  
  // Convert to JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }
  
  // Check if message is expired (older than 5 minutes)
  bool isExpired() {
    return DateTime.now().difference(createdAt).inMinutes >= 5;
  }
  
  // Get short user ID display name
  String get shortUserId => "ANONYMOUS USER";
  
  // Format the time based on the device's locale
  String formatTime(String? locale) {
    final formatter = DateFormat.yMd(locale).add_Hm();
    return formatter.format(createdAt.toLocal());
  }
}
