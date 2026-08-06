class ChatsEntity {
  final String chatId;
  final int type;
  final int participantCount;
  final String createdAt;
  final String chatName;
  final String chatAvatarUrl; // Сделали опциональным для безопасности
  final bool isOnline;
  final int unreadCount;
  final ChatsEntityField lastMessage;

  ChatsEntity({
    required this.chatId,
    required this.type,
    required this.participantCount,
    required this.createdAt,
    required this.chatName,
    required this.chatAvatarUrl,
    required this.isOnline,
    required this.unreadCount,
    required this.lastMessage,
  });
}

class ChatsEntityField {
  final String messageId;
  final String senderId;
  final String senderFirstName;
  final int type;
  final String content;
  final String? mediaUrl; // Сделали опциональным
  final String createdAt;

  ChatsEntityField({
    required this.messageId,
    required this.senderId,
    required this.senderFirstName,
    required this.type,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'senderFirstName': senderFirstName,
      'type': type,
      'content': content,
      'mediaUrl': mediaUrl,
      'createdAt': createdAt,
    };
  }

  factory ChatsEntityField.fromJson(Map<String, dynamic> map) {
    return ChatsEntityField(
      messageId: map['messageId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderFirstName: map['senderFirstName'] as String? ?? '',
      type: map['type'] as int? ?? 0,
      content: map['content'] as String? ?? '',
      mediaUrl: map['mediaUrl'] as String?,
      createdAt: map['createdAt'] as String? ?? '',
    );
  }
}
