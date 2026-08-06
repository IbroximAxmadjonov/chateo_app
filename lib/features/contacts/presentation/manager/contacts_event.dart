part of 'contacts_bloc.dart';

sealed class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object?> get props => [];
}

// ─── Системные события ───────────────────────────────────────────────────────

/// Первоначальная загрузка контактов и подписка на стрим
class LoadContactsRequested extends ContactsEvent {
  const LoadContactsRequested();
}

/// Принудительное обновление списка контактов
class RefreshContactsRequested extends ContactsEvent {
  const RefreshContactsRequested();
}

// ─── Пользовательские события ────────────────────────────────────────────────

/// Поиск по контактам
class SearchContactsRequested extends ContactsEvent {
  final String query;

  const SearchContactsRequested({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Добавление контакта
class PutContactRequested extends ContactsEvent {
  final String firstName;
  final String lastName;
  final String phoneNumber;

  const PutContactRequested({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });
}

/// Удаление контакта
class RemoveContactRequested extends ContactsEvent {
  final String contactId;

  const RemoveContactRequested({required this.contactId});

  @override
  List<Object?> get props => [contactId];
}

// ─── Внутренние события (стримы) ─────────────────────────────────────────────

/// Внутреннее событие — новые данные пришли из стрима watchContacts
class _ContactsUpdated extends ContactsEvent {
  final List<ContactsEntity>? contacts;
  final String? error;

  const _ContactsUpdated({this.contacts, this.error});

  @override
  List<Object?> get props => [contacts, error];
}
