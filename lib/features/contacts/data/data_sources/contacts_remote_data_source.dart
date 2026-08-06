import 'dart:async';

import 'package:chateo_app/core/data/data_sources/remote_data_source.dart';
import 'package:chateo_app/core/data/network/dio_network_manager.dart';
import 'package:chateo_app/core/data/network/network_request.dart';
import 'package:chateo_app/core/utils/errors/exception.dart';
import 'package:flutter/foundation.dart';

import '../models/contact_model.dart';

/// Abstract interface for the local test/mock data source.
abstract class ContactsRemoteDataSource {
  Future<List<ContactsModel>> getAllContacts();

  Future<List<ContactsModel>> searchContacts(String query);

  Future<void> putContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  });

  Future<void> removeContact(String contactId);

  Stream<List<ContactsModel>> watchContacts();
}

class ContactsRemoteDataSourceImpl extends RemoteDataSource
    implements ContactsRemoteDataSource {
  final DioNetworkManager dioNetworkManager;

  ContactsRemoteDataSourceImpl({required this.dioNetworkManager});

  @override
  Future<List<ContactsModel>> getAllContacts() async {
    final response = await performRequest<List>(() async {
      final response = await dioNetworkManager.get(
        NetworkRequest(path: '/api/contacts'),
      );
      return response.data;
    });

    return response.map((json) {
      if (json is! Map<String, dynamic>) {
        throw ServerException(message: 'Некорректный элемент списка контактов');
      }
      return ContactsModel.fromJson(json);
    }).toList();
  }

  @override
  Future<List<ContactsModel>> searchContacts(String query) async {
    final response = await performRequest<List>(() async {
      final response = await dioNetworkManager.get(
        NetworkRequest(path: '/api/Search/users', queryParams: {'query': query}),
      );
      return response.data;
    });
    return response.map((json) {
      if (json is! Map<String, dynamic>) {
        throw ServerException(message: 'Некорректный элемент списка контактов');
      }
      return ContactsModel.fromJson(json);
    }).toList();
  }

  @override
  Future<void> putContact({
    required String firstName,
    required String lastName,
    required String phoneNumber,
  }) async {
    await performRequest(() async {
      await dioNetworkManager.post(
        NetworkRequest(
          path: '/api/contacts',
          data: {
            "phoneNumber": phoneNumber,
            "firstName": firstName,
            "lastName": lastName,
          },
        ),
      );
    });
  }

  @override
  Future<void> removeContact(String contactId) async {
    // пока не реализовано в backend
    throw UnimplementedError();
  }

  static const _pollInterval = Duration(minutes: 10);

  @override
  Stream<List<ContactsModel>> watchContacts() {
    late StreamController<List<ContactsModel>> controller;
    Timer? timer;

    Future<void> fetchAndEmit() async {
      try {
        final response = await dioNetworkManager.get(
          NetworkRequest(path: '/api/contacts'),
        );
        if (controller.isClosed) return;

        if (response.data != null && response.data is List) {
          final list = response.data as List;
          final models = list
              .map((json) => ContactsModel.fromJson(json as Map<String, dynamic>))
              .toList();
          controller.add(models);
        } else {
          debugPrint(
            '⚠️ watchContacts remoteDataSource: unexpected response format',
          );
        }
      } catch (e) {
        // Передаём ошибку в стрим — catchOrReturnStream преобразует в Left(Failure)
        // и продолжает жить (cancelOnError: false)
        if (!controller.isClosed) {
          controller.addError(
            ServerException(message: 'Ошибка получения контактов: $e'),
          );
        }
      }
    }

    controller = StreamController<List<ContactsModel>>(
      onListen: () async {
        await fetchAndEmit();
        timer = Timer.periodic(_pollInterval, (_) => fetchAndEmit());
      },
      onCancel: () => timer?.cancel(),
    );

    return controller.stream;
  }
}
