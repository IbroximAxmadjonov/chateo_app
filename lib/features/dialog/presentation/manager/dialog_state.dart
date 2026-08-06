part of 'dialog_bloc.dart';

abstract class DialogState {
  const DialogState();
}

class DialogInitial extends DialogState {
  const DialogInitial();
}

class DialogLoading extends DialogState {
  const DialogLoading();
}

class DialogLoaded extends DialogState {
  final List<DialogEntity> messages;
  final String? nextCursor;
  final bool hasMore;

  // Search
  final bool isSearchMode;
  final String searchQuery;
  final List<DialogEntity> searchResults;

  // Optimistic send
  final bool isSending;

  const DialogLoaded({
    required this.messages,
    this.nextCursor,
    this.hasMore = false,
    this.isSearchMode = false,
    this.searchQuery = '',
    this.searchResults = const [],
    this.isSending = false,
  });

  DialogLoaded copyWith({
    List<DialogEntity>? messages,
    String? nextCursor,
    bool? hasMore,
    bool? isSearchMode,
    String? searchQuery,
    List<DialogEntity>? searchResults,
    bool? isSending,
  }) {
    return DialogLoaded(
      messages: messages ?? this.messages,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isSearchMode: isSearchMode ?? this.isSearchMode,
      searchQuery: searchQuery ?? this.searchQuery,
      searchResults: searchResults ?? this.searchResults,
      isSending: isSending ?? this.isSending,
    );
  }
}

class DialogError extends DialogState {
  final String message;
  const DialogError(this.message);
}
