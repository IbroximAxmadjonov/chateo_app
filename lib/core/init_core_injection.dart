import 'package:chateo_app/core/data/storage/auth_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'data/data_sources/storage_data_source.dart';
import 'data/network/network_info.dart';
import 'data/network/interceptors/auth_interceptor.dart';
import 'data/network/dio_network_manager.dart';
import 'utils/bloc/theme/theme_bloc.dart';

Future<void> initCoreInjection(GetIt sl) async {
  /// Theme Bloc
  sl.registerFactory(() => ThemeBloc());

  /// Network
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  sl.registerLazySingleton<DioNetworkManager>(
    () => DioNetworkManager(dio: sl(), auth2interceptor: sl()),
  );
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(authStorage: sl(), dio: sl()),
  );

  /// Storage — auth
  final authStorage = AuthStorage();
  await authStorage.init();
  sl.registerSingleton<AuthStorage>(authStorage);

  /// Storage — universal file/media upload (S3/MinIO via presigned URLs)
  sl.registerLazySingleton<StorageDataSource>(
    () => StorageDataSourceImpl(dioNetworkManager: sl()),
  );

  // External
  sl.registerLazySingleton<Connectivity>(() => Connectivity());
  sl.registerLazySingleton<Dio>(() => Dio());
}
