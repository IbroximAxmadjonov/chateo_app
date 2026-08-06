part of 'contacts_bloc.dart';

sealed class ContactsState extends Equatable {
  const ContactsState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние (до первой загрузки)
class ContactsInitial extends ContactsState {
  const ContactsInitial();
}

/// Загрузка данных
class ContactsLoading extends ContactsState {
  const ContactsLoading();
}

/// Контакты успешно загружены
class ContactsLoaded extends ContactsState {
  /// Полный список контактов из репозитория
  final List<ContactsEntity> contacts;

  /// Список после фильтрации поиском (равен [contacts], если поиск пуст)
  final List<ContactsEntity> filteredContacts;

  /// Текущий поисковый запрос
  final String searchQuery;

  const ContactsLoaded({
    required this.contacts,
    this.filteredContacts = const [],
    this.searchQuery = '',
  });

  /// Возвращает список для отображения: filtered при активном поиске, иначе полный
  List<ContactsEntity> get displayContacts => isSearchMode ? filteredContacts : contacts;

  /// Признак активного режима поиска
  bool get isSearchMode => searchQuery.isNotEmpty;

  ContactsLoaded copyWith({
    List<ContactsEntity>? contacts,
    List<ContactsEntity>? filteredContacts,
    String? searchQuery,
  }) {
    return ContactsLoaded(
      contacts: contacts ?? this.contacts,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [contacts, filteredContacts, searchQuery];
}

/// Ошибка загрузки или операции
class ContactsError extends ContactsState {
  final String message;

  const ContactsError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Успешное добавление контакта
class ContactPutSuccess extends ContactsState {
  const ContactPutSuccess();
}

