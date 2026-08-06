import 'package:chateo_app/features/chats/domain/use_cases/create_private_chat_use_case.dart';
import 'package:get_it/get_it.dart';

import 'data/data_sources/chats_remote_data_source.dart';
import 'data/repositories/chats_repository_impl.dart';
import 'domain/repositories/chats_repository.dart';
import 'domain/use_cases/get_all_chats_use_case.dart';
import 'domain/use_cases/remove_chat_use_case.dart';
import 'domain/use_cases/search_chats_use_case.dart';
import 'domain/use_cases/watch_chats_use_case.dart';
import 'presentation/manager/chats_bloc.dart';

void initChatsInjection(GetIt sl) {
  /// Chats Bloc
  sl.registerFactory(
    () => ChatsBloc(
      getAllChatsUseCase: sl(),
      createPrivateChatUseCase: sl(),
      removeChatUseCase: sl(),
      searchChatsUseCase: sl(),
      watchChatsUseCase: sl(),
    ),
  );

  /// Chats Use Cases
  sl.registerLazySingleton(() => GetAllChatsUseCase(chatsRepository: sl()));
  sl.registerLazySingleton(() => CreatePrivateChatUseCase(chatsRepository: sl()));
  sl.registerLazySingleton(() => RemoveChatUseCase(chatsRepository: sl()));
  sl.registerLazySingleton(() => SearchChatsUseCase(chatsRepository: sl()));
  sl.registerLazySingleton(() => WatchChatsUseCase(chatsRepository: sl()));

  /// Chats Repository
  sl.registerLazySingleton<ChatsRepository>(
    () => ChatsRepositoryImpl(chatsRemoteDataSource: sl()),
  );

  /// Chats Remote Data Source
  sl.registerLazySingleton<ChatsRemoteDataSource>(
    () => ChatsRemoteDataSourceImpl(dioNetworkManager: sl()),
  );
}
