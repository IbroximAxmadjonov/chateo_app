part of 'chats_bloc.dart';

sealed class ChatsEvent extends Equatable {
  const ChatsEvent();

  @override
  List<Object?> get props => [];
}

// ─── Системные события ───────────────────────────────────────────────────────

/// Первоначальная загрузка чатов и подписка на стрим
class LoadChatsRequested extends ChatsEvent {
  const LoadChatsRequested();
}

/// Принудительное обновление списка чатов
class RefreshChatsRequested extends ChatsEvent {
  const RefreshChatsRequested();
}

// ─── Пользовательские события ────────────────────────────────────────────────

/// Поиск по чатам
class SearchChatsRequested extends ChatsEvent {
  final String query;

  const SearchChatsRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Создание приватного чата
class CreatePrivateChatRequested extends ChatsEvent {
  final String otherUserId;

  const CreatePrivateChatRequested({required this.otherUserId});

  @override
  List<Object?> get props => [otherUserId];
}

/// Удаление чата
class RemoveChatRequested extends ChatsEvent {
  final String chatId;

  const RemoveChatRequested({required this.chatId});

  @override
  List<Object?> get props => [chatId];
}

// ─── Внутренние события (стримы) ─────────────────────────────────────────────

/// Внутреннее событие — новые данные пришли из стрима watchChats
class _ChatsUpdated extends ChatsEvent {
  final List<ChatsEntity>? chats;
  final String? error;

  const _ChatsUpdated({this.chats, this.error});

  @override
  List<Object?> get props => [chats, error];
}
