import 'package:get_it/get_it.dart';

import 'data/data_sources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/use_cases/delete_account_use_case.dart';
import 'domain/use_cases/logout_use_case.dart';
import 'domain/use_cases/send_otp_use_case.dart';
import 'domain/use_cases/verify_otp_use_case.dart';
import 'presentation/manager/auth_bloc.dart';

void initAuthInjection(GetIt sl) {
  /// Auth Bloc
  sl.registerFactory(
    () => AuthBloc(
      sendOtpUseCase: sl(),
      verifyOtpUseCase: sl(),
      logoutUseCase: sl(),
      deleteAccountUseCase: sl(),
      authStorage: sl(),
    ),
  );

  /// Auth Use Cases
  sl.registerLazySingleton(() => SendOtpUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => LogoutUseCase(authRepository: sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(authRepository: sl()));

  /// Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authRemoteDataSource: sl()),
  );

  /// Auth Remote Data Source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioNetworkManager: sl()),
  );
}
