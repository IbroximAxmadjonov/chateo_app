import 'package:chateo_app/features/contacts/domain/use_cases/put_contact_use_case.dart';
import 'package:get_it/get_it.dart';

import 'data/data_sources/contacts_remote_data_source.dart';
import 'data/repositories/contacts_repository_impl.dart';
import 'domain/repositories/contacts_repository.dart';
import 'domain/use_cases/get_all_contacts_use_case.dart';
import 'domain/use_cases/remove_contact_use_case.dart';
import 'domain/use_cases/search_contacts_use_case.dart';
import 'domain/use_cases/watch_contacts_use_case.dart';
import 'presentation/manager/contacts_bloc.dart';

void initContactsInjection(GetIt sl) {
  /// Contacts Bloc
  sl.registerFactory(
    () => ContactsBloc(
      getAllContactsUseCase: sl(),
      putContactUseCase: sl(),
      removeContactUseCase: sl(),
      searchContactsUseCase: sl(),
      watchContactsUseCase: sl(),
    ),
  );

  /// Contacts Use Cases
  sl.registerLazySingleton(() => GetAllContactsUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(() => PutContactUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(() => RemoveContactUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(() => SearchContactsUseCase(contactsRepository: sl()));
  sl.registerLazySingleton(() => WatchContactsUseCase(contactsRepository: sl()));

  /// Contacts Repository
  sl.registerLazySingleton<ContactsRepository>(
    () => ContactsRepositoryImpl(contactsRemoteDataSource: sl()),
  );

  /// Contacts Local Data Source (test/mock)
  sl.registerLazySingleton<ContactsRemoteDataSource>(
    () => ContactsRemoteDataSourceImpl(dioNetworkManager: sl()),
  );
}
