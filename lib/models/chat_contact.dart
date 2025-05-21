// lib/models/chat_contact.dart
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

  // Convert from Map to ChatContact
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
}
