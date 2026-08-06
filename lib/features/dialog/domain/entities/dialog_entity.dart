class DialogEntity {
  final String messageId;
  final String chatId;
  final String senderId;
  final String senderFirstName;
  final String senderAvatarUrl;
  final int type; // 0: Text, 1: Image, 2: Audio
  final String? content;
  final String? mediaUrl;
  final String? replyToMessageId;
  final int? duration;
  final DateTime createdAt;
  final int myStatus; // 0: sent, 1: read

  const DialogEntity({
    required this.messageId,
    required this.chatId,
    required this.senderId,
    required this.senderFirstName,
    required this.senderAvatarUrl,
    required this.type,
    this.content,
    this.mediaUrl,
    this.replyToMessageId,
    this.duration,
    required this.createdAt,
    required this.myStatus,
  });
}
