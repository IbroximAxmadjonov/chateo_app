import 'dart:async';

import 'package:chateo_app/core/domain/use_case/use_case.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../domain/entities/contacts_entity.dart';
import '../../domain/use_cases/get_all_contacts_use_case.dart';
import '../../domain/use_cases/put_contact_use_case.dart';
import '../../domain/use_cases/remove_contact_use_case.dart';
import '../../domain/use_cases/search_contacts_use_case.dart';
import '../../domain/use_cases/watch_contacts_use_case.dart';

part 'contacts_event.dart';

part 'contacts_state.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  final GetAllContactsUseCase getAllContactsUseCase;
  final PutContactUseCase putContactUseCase;
  final RemoveContactUseCase removeContactUseCase;
  final SearchContactsUseCase searchContactsUseCase;
  final WatchContactsUseCase watchContactsUseCase;

  StreamSubscription? _contactsSubscription;

  ContactsBloc({
    required this.getAllContactsUseCase,
    required this.putContactUseCase,
    required this.removeContactUseCase,
    required this.searchContactsUseCase,
    required this.watchContactsUseCase,
  }) : super(const ContactsInitial()) {
    on<LoadContactsRequested>(_onLoadContacts);
    on<RefreshContactsRequested>(_onRefreshContacts);
    on<SearchContactsRequested>(_onSearchContacts);
    on<PutContactRequested>(_onPutContact);
    on<RemoveContactRequested>(_onRemoveContact);
    on<_ContactsUpdated>(_onContactsUpdated);
  }

  /// Загрузка контактов — подписываемся на стрим из репозитория
  FutureOr<void> _onLoadContacts(
    LoadContactsRequested event,
    Emitter<ContactsState> emit,
  ) async {
    emit(const ContactsLoading());

    await _contactsSubscription?.cancel();

    _contactsSubscription = watchContactsUseCase.call(NoParams()).listen((result) {
      result.fold(
        (failure) => add(_ContactsUpdated(error: failure.message)),
        (contacts) => add(_ContactsUpdated(contacts: contacts)),
      );
    });
  }

  /// Обновление из стрима (внутреннее событие)
  void _onContactsUpdated(_ContactsUpdated event, Emitter<ContactsState> emit) {
    if (event.error != null) {
      emit(ContactsError(event.error!));
      return;
    }

    final contacts = event.contacts ?? [];

    final currentQuery = state is ContactsLoaded
        ? (state as ContactsLoaded).searchQuery
        : '';

    final filtered = currentQuery.isEmpty
        ? contacts
        : contacts
              .where(
                (c) => c.fullName.toLowerCase().contains(currentQuery.toLowerCase()),
              )
              .toList();

    emit(
      ContactsLoaded(
        contacts: contacts,
        filteredContacts: filtered,
        searchQuery: currentQuery,
      ),
    );
  }

  /// Принудительное обновление — перезагружаем через getContacts
  FutureOr<void> _onRefreshContacts(
    RefreshContactsRequested event,
    Emitter<ContactsState> emit,
  ) async {
    final currentState = state;
    // Не показываем полный лоадинг при обновлении, если список уже есть
    if (currentState is! ContactsLoaded) {
      emit(const ContactsLoading());
    }

    final result = await getAllContactsUseCase(NoParams());

    result.fold((failure) => emit(ContactsError(failure.message)), (contacts) {
      final currentQuery = currentState is ContactsLoaded
          ? currentState.searchQuery
          : '';

      final filtered = currentQuery.isEmpty
          ? contacts
          : contacts
                .where(
                  (c) =>
                      c.fullName.toLowerCase().contains(currentQuery.toLowerCase()),
                )
                .toList();

      emit(
        ContactsLoaded(
          contacts: contacts,
          filteredContacts: filtered,
          searchQuery: currentQuery,
        ),
      );
    });
  }

  /// Поиск среди загруженных контактов (локальная фильтрация)
  FutureOr<void> _onSearchContacts(
    SearchContactsRequested event,
    Emitter<ContactsState> emit,
  ) async {
    final currentState = state;

    if (currentState is ContactsLoaded) {
      final query = event.query.trim();

      if (query.isEmpty) {
        emit(
          currentState.copyWith(
            filteredContacts: currentState.contacts,
            searchQuery: '',
          ),
        );
        return;
      }

      // Локальная фильтрация для моментального отклика UI
      final localFiltered = currentState.contacts
          .where((c) => c.fullName.toLowerCase().contains(query.toLowerCase()))
          .toList();

      emit(
        currentState.copyWith(filteredContacts: localFiltered, searchQuery: query),
      );

      // Серверный поиск для более точных результатов
      final result = await searchContactsUseCase(SearchContactsParams(query: query));

      result.fold(
        (failure) {
          // При ошибке оставляем локальную фильтрацию
        },
        (serverContacts) {
          if (isClosed) return;
          emit(
            currentState.copyWith(
              filteredContacts: serverContacts,
              searchQuery: query,
            ),
          );
        },
      );
    }
  }

  FutureOr<void> _onPutContact(
    PutContactRequested event,
    Emitter<ContactsState> emit,
  ) async {
    final result = await putContactUseCase(
      PutContactUseCaseParams(
        firstName: event.firstName,
        lastName: event.lastName,
        phoneNumber: event.phoneNumber,
      ),
    );

    result.fold(
      (failure) => emit(ContactsError(failure.message)),
      (_) {
        emit(const ContactPutSuccess());
        add(const RefreshContactsRequested());
      },
    );
  }

  /// Удаление контакта
  FutureOr<void> _onRemoveContact(
    RemoveContactRequested event,
    Emitter<ContactsState> emit,
  ) async {
    final result = await removeContactUseCase(
      RemoveContactParams(contactId: event.contactId),
    );

    result.fold((failure) => emit(ContactsError(failure.message)), (_) {
      final currentState = state;
      if (currentState is ContactsLoaded) {
        final updated = currentState.contacts
            .where((c) => c.contactUserId != event.contactId)
            .toList();
        final filteredUpdated = currentState.filteredContacts
            .where((c) => c.contactUserId != event.contactId)
            .toList();
        emit(
          currentState.copyWith(
            contacts: updated,
            filteredContacts: filteredUpdated,
          ),
        );
      }
    });
  }

  @override
  Future<void> close() {
    _contactsSubscription?.cancel();
    return super.close();
  }
}
