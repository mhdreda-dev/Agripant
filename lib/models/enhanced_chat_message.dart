// lib/models/enhanced_chat_message.dart

enum MessageType {
  text,
  image,
  file,
  system,
  typing,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class EnhancedChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final MessageType type;
  final MessageStatus status;
  final String? imageUrl;
  final String? fileName;
  final Map<String, dynamic>? metadata;
  final String? replyToId;
  final List<String>? reactions;

  EnhancedChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.type = MessageType.text,
    this.status = MessageStatus.sent,
    this.imageUrl,
    this.fileName,
    this.metadata,
    this.replyToId,
    this.reactions,
  }) : timestamp = timestamp ?? DateTime.now();

  // Constructeur pour les messages de typing
  EnhancedChatMessage.typing({
    required this.id,
    required this.isUser,
  })  : text = '',
        timestamp = DateTime.now(),
        type = MessageType.typing,
        status = MessageStatus.sending,
        imageUrl = null,
        fileName = null,
        metadata = null,
        replyToId = null,
        reactions = null;

  // Constructeur pour les messages système
  EnhancedChatMessage.system({
    required this.id,
    required this.text,
    DateTime? timestamp,
  })  : isUser = false,
        timestamp = timestamp ?? DateTime.now(),
        type = MessageType.system,
        status = MessageStatus.sent,
        imageUrl = null,
        fileName = null,
        metadata = null,
        replyToId = null,
        reactions = null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'imageUrl': imageUrl,
      'fileName': fileName,
      'metadata': metadata,
      'replyToId': replyToId,
      'reactions': reactions,
    };
  }

  factory EnhancedChatMessage.fromJson(Map<String, dynamic> json) {
    return EnhancedChatMessage(
      id: json['id'] ?? '',
      text: json['text'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      imageUrl: json['imageUrl'],
      fileName: json['fileName'],
      metadata: json['metadata'],
      replyToId: json['replyToId'],
      reactions: json['reactions']?.cast<String>(),
    );
  }

  // Copie avec modifications
  EnhancedChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    MessageType? type,
    MessageStatus? status,
    String? imageUrl,
    String? fileName,
    Map<String, dynamic>? metadata,
    String? replyToId,
    List<String>? reactions,
  }) {
    return EnhancedChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      fileName: fileName ?? this.fileName,
      metadata: metadata ?? this.metadata,
      replyToId: replyToId ?? this.replyToId,
      reactions: reactions ?? this.reactions,
    );
  }

  bool get isImage => type == MessageType.image && imageUrl != null;
  bool get isFile => type == MessageType.file && fileName != null;
  bool get isSystem => type == MessageType.system;
  bool get isTyping => type == MessageType.typing;
  bool get hasReactions => reactions != null && reactions!.isNotEmpty;
  bool get isReply => replyToId != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedChatMessage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Extensions utiles
extension ChatMessageExtensions on EnhancedChatMessage {
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}j';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}min';
    } else {
      return 'maintenant';
    }
  }

  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  bool get canBeDeleted => isUser && status != MessageStatus.failed;
  bool get canBeEdited =>
      isUser && type == MessageType.text && status == MessageStatus.sent;
}
