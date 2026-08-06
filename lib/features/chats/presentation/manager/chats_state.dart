part of 'chats_bloc.dart';

sealed class ChatsState extends Equatable {
  const ChatsState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние (до первой загрузки)
class ChatsInitial extends ChatsState {
  const ChatsInitial();
}

/// Загрузка данных
class ChatsLoading extends ChatsState {
  const ChatsLoading();
}

/// Чаты успешно загружены
class ChatsLoaded extends ChatsState {
  /// Полный список чатов из репозитория
  final List<ChatsEntity> chats;

  /// Список после фильтрации поиском (равен [chats], если поиск пуст)
  final List<ChatsEntity> filteredChats;

  /// Текущий поисковый запрос
  final String searchQuery;

  const ChatsLoaded({
    required this.chats,
    this.filteredChats = const [],
    this.searchQuery = '',
  });

  /// Возвращает список для отображения: filtered при активном поиске, иначе полный
  List<ChatsEntity> get displayChats => isSearchMode ? filteredChats : chats;

  /// Признак активного режима поиска
  bool get isSearchMode => searchQuery.isNotEmpty;

  ChatsLoaded copyWith({
    List<ChatsEntity>? chats,
    List<ChatsEntity>? filteredChats,
    String? searchQuery,
  }) {
    return ChatsLoaded(
      chats: chats ?? this.chats,
      filteredChats: filteredChats ?? this.filteredChats,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [chats, filteredChats, searchQuery];
}

/// Ошибка загрузки или операции
class ChatsError extends ChatsState {
  final String message;

  const ChatsError(this.message);

  @override
  List<Object?> get props => [message];
}
