import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  // 🔁 Pour SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  // 🔥 Pour Firestore (lecture)
  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      text: data['text'] ?? '',
      isUser: data['isUser'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // 🔥 Pour Firestore (écriture)
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
