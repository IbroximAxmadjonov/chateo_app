part of 'dialog_bloc.dart';

abstract class DialogEvent {
  const DialogEvent();
}

/// Load (or reload) messages for [chatId]. Pass [before] for pagination.
class LoadMessagesRequested extends DialogEvent {
  final String chatId;
  final String? before;
  final bool isLoadMore;

  const LoadMessagesRequested({
    required this.chatId,
    this.before,
    this.isLoadMore = false,
  });
}

/// Send a text (type=0) message.
class SendMessageRequested extends DialogEvent {
  final String chatId;
  final int type;
  final String? content;
  final String? mediaUrl;
  final int? duration;
  final String? replyToMessageId;

  const SendMessageRequested({
    required this.chatId,
    required this.type,
    this.content,
    this.mediaUrl,
    this.duration,
    this.replyToMessageId,
  });
}

/// Mark all messages up to [upToMessageId] as read.
class MarkReadRequested extends DialogEvent {
  final String chatId;
  final String upToMessageId;

  const MarkReadRequested({
    required this.chatId,
    required this.upToMessageId,
  });
}

/// Search messages within the chat.
class SearchMessagesRequested extends DialogEvent {
  final String chatId;
  final String query;

  const SearchMessagesRequested({
    required this.chatId,
    required this.query,
  });
}

/// Clear search results and go back to normal message list.
class ClearSearchRequested extends DialogEvent {
  const ClearSearchRequested();
}
