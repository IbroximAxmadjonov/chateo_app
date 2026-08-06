import 'dart:async';

import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:chateo_app/features/chats/domain/use_cases/create_private_chat_use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/chats_entity.dart';
import '../../domain/use_cases/get_all_chats_use_case.dart';
import '../../domain/use_cases/remove_chat_use_case.dart';
import '../../domain/use_cases/search_chats_use_case.dart';
import '../../domain/use_cases/watch_chats_use_case.dart';

part 'chats_event.dart';

part 'chats_state.dart';

class ChatsBloc extends Bloc<ChatsEvent, ChatsState> {
  final GetAllChatsUseCase getAllChatsUseCase;
  final CreatePrivateChatUseCase createPrivateChatUseCase;
  final RemoveChatUseCase removeChatUseCase;
  final SearchChatsUseCase searchChatsUseCase;
  final WatchChatsUseCase watchChatsUseCase;

  StreamSubscription? _chatsSubscription;

  ChatsBloc({
    required this.getAllChatsUseCase,
    required this.createPrivateChatUseCase,
    required this.removeChatUseCase,
    required this.searchChatsUseCase,
    required this.watchChatsUseCase,
  }) : super(const ChatsInitial()) {
    on<LoadChatsRequested>(_onLoadChats);
    on<CreatePrivateChatRequested>(_onCreatePrivateChat);
    on<RefreshChatsRequested>(_onRefreshChats);
    on<SearchChatsRequested>(_onSearchChats);
    on<RemoveChatRequested>(_onRemoveChat);
    on<_ChatsUpdated>(_onChatsUpdated);
  }

  /// Загрузка чатов — подписываемся на стрим из репозитория
  FutureOr<void> _onLoadChats(
    LoadChatsRequested event,
    Emitter<ChatsState> emit,
  ) async {
    emit(const ChatsLoading());

    await _chatsSubscription?.cancel();

    _chatsSubscription = watchChatsUseCase
        .call(NoParams())
        .listen(
          (result) {
            result.fold(
              (failure) => add(_ChatsUpdated(error: failure.message)),
              (chats) => add(_ChatsUpdated(chats: chats)),
            );
          },
          // Страховка: если ошибка всё же проскочила через репозиторий
          onError: (Object error) {
            add(_ChatsUpdated(error: error.toString()));
          },
          cancelOnError: false,
        );
  }

  /// Обновление из стрима (внутреннее событие)
  void _onChatsUpdated(_ChatsUpdated event, Emitter<ChatsState> emit) {
    if (event.error != null) {
      emit(ChatsError(event.error!));
      return;
    }

    final chats = event.chats ?? [];

    final currentQuery = state is ChatsLoaded
        ? (state as ChatsLoaded).searchQuery
        : '';

    final filtered = currentQuery.isEmpty
        ? chats
        : chats
              .where(
                (c) => c.chatName.toLowerCase().contains(currentQuery.toLowerCase()),
              )
              .toList();

    emit(
      ChatsLoaded(chats: chats, filteredChats: filtered, searchQuery: currentQuery),
    );
  }

  FutureOr<void> _onCreatePrivateChat(
    CreatePrivateChatRequested event,
    Emitter<ChatsState> emit,
  ) async {
    final result = await createPrivateChatUseCase(
      CreatePrivateChatParams(otherUserId: event.otherUserId),
    );

    result.fold(
      (failure) => emit(ChatsError(failure.message)),
      (_) {
        add(const RefreshChatsRequested());
      },
    );
  }

  /// Принудительное обновление
  FutureOr<void> _onRefreshChats(
    RefreshChatsRequested event,
    Emitter<ChatsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ChatsLoaded) {
      emit(const ChatsLoading());
    }

    final result = await getAllChatsUseCase(NoParams());

    result.fold((failure) => emit(ChatsError(failure.message)), (chats) {
      final currentQuery = currentState is ChatsLoaded
          ? currentState.searchQuery
          : '';

      final filtered = currentQuery.isEmpty
          ? chats
          : chats
                .where(
                  (c) =>
                      c.chatName.toLowerCase().contains(currentQuery.toLowerCase()),
                )
                .toList();

      emit(
        ChatsLoaded(
          chats: chats,
          filteredChats: filtered,
          searchQuery: currentQuery,
        ),
      );
    });
  }

  /// Поиск среди загруженных чатов (локальная фильтрация)
  FutureOr<void> _onSearchChats(
    SearchChatsRequested event,
    Emitter<ChatsState> emit,
  ) async {
    final currentState = state;

    if (currentState is ChatsLoaded) {
      final query = event.query.trim();

      if (query.isEmpty) {
        emit(
          currentState.copyWith(filteredChats: currentState.chats, searchQuery: ''),
        );
        return;
      }

      // Локальная фильтрация для моментального отклика UI
      final localFiltered = currentState.chats
          .where((c) => c.chatName.toLowerCase().contains(query.toLowerCase()))
          .toList();

      emit(currentState.copyWith(filteredChats: localFiltered, searchQuery: query));

      // Серверный поиск для более точных результатов
      final result = await searchChatsUseCase(SearchChatsParams(query: query));

      result.fold(
        (failure) {
          // При ошибке оставляем локальную фильтрацию
        },
        (serverChats) {
          if (isClosed) return;
          emit(
            currentState.copyWith(filteredChats: serverChats, searchQuery: query),
          );
        },
      );
    }
  }

  /// Удаление чата
  FutureOr<void> _onRemoveChat(
    RemoveChatRequested event,
    Emitter<ChatsState> emit,
  ) async {
    final result = await removeChatUseCase(RemoveChatParams(chatId: event.chatId));

    result.fold((failure) => emit(ChatsError(failure.message)), (_) {
      final currentState = state;
      if (currentState is ChatsLoaded) {
        final updated = currentState.chats
            .where((c) => c.chatId != event.chatId)
            .toList();
        final filteredUpdated = currentState.filteredChats
            .where((c) => c.chatId != event.chatId)
            .toList();
        emit(currentState.copyWith(chats: updated, filteredChats: filteredUpdated));
      }
    });
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
