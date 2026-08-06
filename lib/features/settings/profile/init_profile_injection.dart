import 'package:get_it/get_it.dart';

import 'data/data_sources/profile_cache_service.dart';
import 'data/data_sources/profile_remote_data_source.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'domain/repositories/profile_repository.dart';
import 'domain/use_cases/get_profile_use_case.dart';
import 'domain/use_cases/put_profile_use_case.dart';
import 'domain/use_cases/upload_avatar_use_case.dart';
import 'presentation/manager/profile_bloc.dart';

void initProfileInjection(GetIt sl) {
  /// Profile Bloc
  sl.registerFactory(
    () => ProfileBloc(
      getProfileUseCase: sl(),
      putProfileUseCase: sl(),
      uploadAvatarUseCase: sl(),
      cacheService: sl(),
    ),
  );

  /// Profile Cache Service
  sl.registerLazySingleton(() => ProfileCacheService());

  /// Profile Use Cases
  sl.registerLazySingleton(() => GetProfileUseCase(profileRepository: sl()));
  sl.registerLazySingleton(() => PutProfileUseCase(profileRepository: sl()));
  sl.registerLazySingleton(
    () => UploadAvatarUseCase(storageDataSource: sl()),
  );

  /// Profile Repository
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(profileRemoteDataSource: sl()),
  );

  /// Profile Remote Data Source
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dioNetworkManager: sl()),
  );
}
