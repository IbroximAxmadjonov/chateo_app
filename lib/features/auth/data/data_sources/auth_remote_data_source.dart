import 'package:chateo_app/core/data/data_sources/remote_data_source.dart';
import 'package:chateo_app/core/data/network/dio_network_manager.dart';
import 'package:chateo_app/core/data/network/network_request.dart';
import 'package:chateo_app/core/utils/api_constant.dart';

abstract class AuthRemoteDataSource {
  Future<void> sendOtp({required String phoneNumber});

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
  });

  Future<Map<String, dynamic>> refreshToken({required String refreshToken});

  Future<void> logout();

  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl extends RemoteDataSource
    implements AuthRemoteDataSource {
  final DioNetworkManager dioNetworkManager;

  AuthRemoteDataSourceImpl({required this.dioNetworkManager});

  @override
  Future<void> sendOtp({required String phoneNumber}) async {
    // Сервер возвращает 204 No Content — тело ответа пустое, это норма.
    await performRequest<void>(() async {
      final response = await dioNetworkManager.post(
        NetworkRequest(
          path: ApiConstant.sendOtpUrl,
          data: {"phoneNumber": phoneNumber},
        ),
      );
      return response.data;
    });
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    return await performRequest<Map<String, dynamic>>(() async {
      final response = await dioNetworkManager.post(
        NetworkRequest(
          path: ApiConstant.verifyOtpUrl,
          data: {"phoneNumber": phone, "code": code},
        ),
      );
      return response.data;
    });
  }

  @override
  Future<Map<String, dynamic>> refreshToken({required String refreshToken}) async {
    return await performRequest<Map<String, dynamic>>(() async {
      final response = await dioNetworkManager.post(
        NetworkRequest(
          path: ApiConstant.refreshUrl,
          data: {"refreshToken": refreshToken},
        ),
      );
      return response.data;
    });
  }

  @override
  Future<void> logout() async {
    await performRequest<void>(() async {
      await dioNetworkManager.post(NetworkRequest(path: ''));
    });
  }

  @override
  Future<void> deleteAccount() async {
    await performRequest<void>(() async {
      await dioNetworkManager.delete(NetworkRequest(path: ''));
    });
  }
}
