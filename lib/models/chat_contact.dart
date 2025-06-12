// lib/models/chat_contact.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatContact {
  final int userId;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? accountType;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatContact({
    required this.userId,
    required this.username,
    this.firstName,
    this.lastName,
    this.accountType,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else {
      return username;
    }
  }

  // 🔁 Depuis Firestore (lecture)
  factory ChatContact.fromFirestore(Map<String, dynamic> data) {
    return ChatContact(
      userId: data['userId'],
      username: data['username'],
      firstName: data['firstName'],
      lastName: data['lastName'],
      accountType: data['accountType'],
      lastMessage: data['lastMessage'],
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      unreadCount: data['unreadCount'] ?? 0,
    );
  }

  // 🔁 Depuis Map générique
  factory ChatContact.fromMap(Map<String, dynamic> map) {
    return ChatContact(
      userId: map['userId'],
      username: map['username'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      accountType: map['accountType'],
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.parse(map['lastMessageTime'])
          : null,
      unreadCount: map['unreadCount'] ?? 0,
    );
  }

  // 🔄 Vers Firestore (écriture)
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'accountType': accountType,
      'lastMessage': lastMessage,
      'lastMessageTime':
          lastMessageTime != null ? Timestamp.fromDate(lastMessageTime!) : null,
      'unreadCount': unreadCount,
    };
  }

  // 🔄 Vers Map générique
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'accountType': accountType,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.toIso8601String(),
      'unreadCount': unreadCount,
    };
  }
}
