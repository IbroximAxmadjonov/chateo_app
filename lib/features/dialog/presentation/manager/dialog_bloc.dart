import 'dart:async';

import 'package:chateo_app/features/dialog/domain/entities/dialog_entity.dart';
import 'package:chateo_app/features/dialog/domain/use_cases/get_messages_use_case.dart';
import 'package:chateo_app/features/dialog/domain/use_cases/mark_read_use_case.dart';
import 'package:chateo_app/features/dialog/domain/use_cases/search_messages_use_case.dart';
import 'package:chateo_app/features/dialog/domain/use_cases/send_message_use_case.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'dialog_event.dart';
part 'dialog_state.dart';

class DialogBloc extends Bloc<DialogEvent, DialogState> {
  final GetMessagesUseCase getMessagesUseCase;
  final SendMessageUseCase sendMessageUseCase;
  final MarkReadUseCase markReadUseCase;
  final SearchMessagesUseCase searchMessagesUseCase;

  DialogBloc({
    required this.getMessagesUseCase,
    required this.sendMessageUseCase,
    required this.markReadUseCase,
    required this.searchMessagesUseCase,
  }) : super(const DialogInitial()) {
    on<LoadMessagesRequested>(_onLoadMessages);
    on<SendMessageRequested>(_onSendMessage);
    on<MarkReadRequested>(_onMarkRead);
    on<SearchMessagesRequested>(_onSearchMessages);
    on<ClearSearchRequested>(_onClearSearch);
  }

  // ── Load messages ──────────────────────────────────────────────────────────

  FutureOr<void> _onLoadMessages(
    LoadMessagesRequested event,
    Emitter<DialogState> emit,
  ) async {
    final currentState = state;

    if (!event.isLoadMore) {
      emit(const DialogLoading());
    }

    final result = await getMessagesUseCase(
      GetMessagesParams(
        chatId: event.chatId,
        before: event.before,
        limit: 50,
      ),
    );

    result.fold(
      (failure) => emit(DialogError(failure.message)),
      (newMessages) {
        final existing = (currentState is DialogLoaded && event.isLoadMore)
            ? currentState.messages
            : <DialogEntity>[];

        // Merge: новые добавляем в конец (или снизу, т.к. ListView.reversed)
        final merged = [...existing, ...newMessages];

        emit(
          DialogLoaded(
            messages: merged,
            hasMore: newMessages.length == 50,
          ),
        );
      },
    );
  }

  // ── Send message ────────────────────────────────────────────────────────────

  FutureOr<void> _onSendMessage(
    SendMessageRequested event,
    Emitter<DialogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DialogLoaded) return;

    emit(currentState.copyWith(isSending: true));

    final result = await sendMessageUseCase(
      SendMessageParams(
        chatId: event.chatId,
        type: event.type,
        content: event.content,
        mediaUrl: event.mediaUrl,
        duration: event.duration,
        replyToMessageId: event.replyToMessageId,
      ),
    );

    result.fold(
      (failure) {
        emit(currentState.copyWith(isSending: false));
        // re-emit error as separate DialogError would close page — use snackbar instead
        emit(DialogError(failure.message));
      },
      (newMessage) {
        final updated = [...currentState.messages, newMessage];
        emit(currentState.copyWith(messages: updated, isSending: false));
      },
    );
  }

  // ── Mark read ───────────────────────────────────────────────────────────────

  FutureOr<void> _onMarkRead(
    MarkReadRequested event,
    Emitter<DialogState> emit,
  ) async {
    await markReadUseCase(
      MarkReadParams(
        chatId: event.chatId,
        upToMessageId: event.upToMessageId,
      ),
    );
    // No state change needed — the server will reflect on next poll
  }

  // ── Search messages ─────────────────────────────────────────────────────────

  FutureOr<void> _onSearchMessages(
    SearchMessagesRequested event,
    Emitter<DialogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DialogLoaded) return;

    if (event.query.trim().isEmpty) {
      emit(currentState.copyWith(
        isSearchMode: false,
        searchQuery: '',
        searchResults: [],
      ));
      return;
    }

    emit(currentState.copyWith(
      isSearchMode: true,
      searchQuery: event.query,
    ));

    final result = await searchMessagesUseCase(
      SearchMessagesParams(chatId: event.chatId, query: event.query),
    );

    result.fold(
      (failure) {
        // Keep search mode but show empty results on error
        emit(currentState.copyWith(
          isSearchMode: true,
          searchQuery: event.query,
          searchResults: [],
        ));
      },
      (results) {
        emit(currentState.copyWith(
          isSearchMode: true,
          searchQuery: event.query,
          searchResults: results,
        ));
      },
    );
  }

  // ── Clear search ────────────────────────────────────────────────────────────

  FutureOr<void> _onClearSearch(
    ClearSearchRequested event,
    Emitter<DialogState> emit,
  ) {
    final currentState = state;
    if (currentState is DialogLoaded) {
      emit(currentState.copyWith(
        isSearchMode: false,
        searchQuery: '',
        searchResults: [],
      ));
    }
  }
}
