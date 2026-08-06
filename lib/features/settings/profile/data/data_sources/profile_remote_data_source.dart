import 'package:chateo_app/core/data/data_sources/remote_data_source.dart';
import 'package:chateo_app/core/data/network/dio_network_manager.dart';
import 'package:chateo_app/core/data/network/network_request.dart';

import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();

  Future<ProfileModel> putProfile({
    required String firstName,
    required String lastName,
    String? avatarUrl,
  });
}

class ProfileRemoteDataSourceImpl extends RemoteDataSource
    implements ProfileRemoteDataSource {
  final DioNetworkManager dioNetworkManager;

  ProfileRemoteDataSourceImpl({required this.dioNetworkManager});

  @override
  Future<ProfileModel> getProfile() async {
    final response = await performRequest<Map<String, dynamic>>(() async {
      final response = await dioNetworkManager.get(
        NetworkRequest(path: '/api/profile'),
      );
      return response.data;
    });
    return ProfileModel.fromMap(response);
  }

  @override
  Future<ProfileModel> putProfile({
    required String firstName,
    required String lastName,
    String? avatarUrl,
  }) async {
    final response = await performRequest<Map<String, dynamic>>(() async {
      final response = await dioNetworkManager.put(
        NetworkRequest(
          path: '/api/profile',
          data: {
            'firstName': firstName,
            'lastName': lastName,
            'avatarUrl': avatarUrl,
          },
        ),
      );
      return response.data;
    });

    return ProfileModel.fromMap(response);
  }
}
