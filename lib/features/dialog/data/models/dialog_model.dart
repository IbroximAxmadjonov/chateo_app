import '../../domain/entities/dialog_entity.dart';

class DialogModel extends DialogEntity {
  DialogModel({
    required super.messageId,
    required super.chatId,
    required super.senderId,
    required super.senderFirstName,
    required super.senderAvatarUrl,
    required super.type,
    super.content,
    super.mediaUrl,
    super.replyToMessageId,
    super.duration,
    required super.createdAt,
    required super.myStatus,
  });

  factory DialogModel.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate;
    final rawDate = map['createdAt'];
    try {
      parsedDate =
          rawDate is String ? DateTime.parse(rawDate) : DateTime(2000);
    } catch (_) {
      parsedDate = DateTime(2000);
    }

    return DialogModel(
      messageId: map['messageId'] as String? ?? '',
      chatId: map['chatId'] as String? ?? '',
      senderId: map['senderId'] as String? ?? '',
      senderFirstName: map['senderFirstName'] as String? ?? '',
      senderAvatarUrl: map['senderAvatarUrl'] as String? ?? '',
      type: map['type'] as int? ?? 0,
      content: map['content'] as String?,
      mediaUrl: map['mediaUrl'] as String?,
      replyToMessageId: map['replyToMessageId'] as String?,
      duration: map['duration'] as int?,
      createdAt: parsedDate,
      myStatus: map['myStatus'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'senderId': senderId,
      'senderFirstName': senderFirstName,
      'senderAvatarUrl': senderAvatarUrl,
      'type': type,
      'content': content,
      'mediaUrl': mediaUrl,
      'replyToMessageId': replyToMessageId,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'myStatus': myStatus,
    };
  }

  /// Convert to domain entity (identity since model extends entity)
  DialogEntity get toEntity => this;
}
