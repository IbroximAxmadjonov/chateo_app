import '../../domain/entities/chats_entity.dart';

class ChatsModel extends ChatsEntity {
  ChatsModel({
    required super.chatId,
    required super.type,
    required super.participantCount,
    required super.createdAt,
    required super.chatName,
    required super.chatAvatarUrl,
    required super.isOnline,
    required super.unreadCount,
    required super.lastMessage,
  });

  factory ChatsModel.fromJson(Map<String, dynamic> json) {
    return ChatsModel(
      chatId: json['chatId'] as String? ?? '',
      type: json['type'] as int? ?? 0,
      participantCount: json['participantCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String? ?? '',
      chatName: json['chatName'] as String? ?? '',
      chatAvatarUrl: json['chatAvatarUrl'] as String? ?? '',
      isOnline: json['isOnline'] as bool? ?? false,
      unreadCount: json['unreadCount'] as int? ?? 0,
      // Безопасный парсинг: lastMessage может прийти как null от сервера
      lastMessage: json['lastMessage'] != null
          ? ChatsEntityField.fromJson(json['lastMessage'] as Map<String, dynamic>)
          : ChatsEntityField(
              messageId: '',
              senderId: '',
              senderFirstName: '',
              type: 0,
              content: '',
              createdAt: '',
            ),
    );
  }

  factory ChatsModel.fromEntity(ChatsEntity entity) {
    return ChatsModel(
      chatId: entity.chatId,
      type: entity.type,
      participantCount: entity.participantCount,
      createdAt: entity.createdAt,
      chatName: entity.chatName,
      chatAvatarUrl: entity.chatAvatarUrl,
      isOnline: entity.isOnline,
      unreadCount: entity.unreadCount,
      lastMessage: entity.lastMessage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'type': type,
      'participantCount': participantCount,
      'createdAt': createdAt,
      'chatName': chatName,
      'chatAvatarUrl': chatAvatarUrl,
      'isOnline': isOnline,
      'unreadCount': unreadCount,
      'lastMessage': lastMessage.toJson(), // <- Переводим вложенный объект в Map
    };
  }

  ChatsEntity get toEntity {
    return ChatsEntity(
      chatId: chatId,
      type: type,
      participantCount: participantCount,
      createdAt: createdAt,
      chatName: chatName,
      chatAvatarUrl: chatAvatarUrl,
      isOnline: isOnline,
      unreadCount: unreadCount,
      lastMessage: lastMessage,
    );
  }
}
