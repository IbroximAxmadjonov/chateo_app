import 'package:get_it/get_it.dart';

import 'data/data_sources/dialog_remote_data_source.dart';
import 'data/repositories/dialog_repository_impl.dart';
import 'domain/repositories/dialog_repository.dart';
import 'domain/use_cases/get_messages_use_case.dart';
import 'domain/use_cases/mark_read_use_case.dart';
import 'domain/use_cases/search_messages_use_case.dart';
import 'domain/use_cases/send_message_use_case.dart';
import 'presentation/manager/dialog_bloc.dart';

void initDialogInjection(GetIt sl) {
  /// Dialog Bloc
  sl.registerFactory(
    () => DialogBloc(
      getMessagesUseCase: sl(),
      sendMessageUseCase: sl(),
      markReadUseCase: sl(),
      searchMessagesUseCase: sl(),
    ),
  );

  /// Dialog Use Cases
  sl.registerLazySingleton(
      () => GetMessagesUseCase(dialogRepository: sl()));
  sl.registerLazySingleton(
      () => SendMessageUseCase(dialogRepository: sl()));
  sl.registerLazySingleton(() => MarkReadUseCase(dialogRepository: sl()));
  sl.registerLazySingleton(
      () => SearchMessagesUseCase(dialogRepository: sl()));

  /// Dialog Repository
  sl.registerLazySingleton<DialogRepository>(
    () => DialogRepositoryImpl(dialogRemoteDataSource: sl()),
  );

  /// Dialog Remote Data Source
  sl.registerLazySingleton<DialogRemoteDataSource>(
    () => DialogRemoteDataSourceImpl(dioNetworkManager: sl()),
  );
}
