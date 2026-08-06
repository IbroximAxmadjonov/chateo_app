import 'dart:io';

import 'package:chateo_app/core/data/data_sources/remote_data_source.dart';
import 'package:chateo_app/core/data/network/dio_network_manager.dart';
import 'package:chateo_app/core/data/network/network_request.dart';
import 'package:chateo_app/core/utils/errors/exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Response from POST /api/Storage/upload-url
class UploadUrlResponse {
  final String uploadUrl;
  final String fileKey;

  UploadUrlResponse({required this.uploadUrl, required this.fileKey});

  factory UploadUrlResponse.fromMap(Map<String, dynamic> map) {
    return UploadUrlResponse(
      uploadUrl: map['uploadUrl'] as String,
      fileKey: map['fileKey'] as String,
    );
  }
}

/// Universal storage service for uploading any file (avatar, chat media, etc.)
/// via the 2-step presigned URL flow:
///   Step 1 — POST /api/Storage/upload-url  → get { uploadUrl, fileKey }
///   Step 2 — PUT uploadUrl (direct to S3/MinIO, no auth headers)
abstract class StorageDataSource {
  /// Step 1: Request a presigned upload URL from the backend
  Future<UploadUrlResponse> getUploadUrl({
    required String fileName,
    required String contentType,
  });

  /// Step 2: Upload the file bytes directly to S3/MinIO via the presigned URL
  Future<void> uploadFileToStorage({
    required String uploadUrl,
    required File file,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  });
}

class StorageDataSourceImpl extends RemoteDataSource implements StorageDataSource {
  final DioNetworkManager dioNetworkManager;

  StorageDataSourceImpl({required this.dioNetworkManager});

  @override
  Future<UploadUrlResponse> getUploadUrl({
    required String fileName,
    required String contentType,
  }) async {
    final response = await performRequest<Map<String, dynamic>>(() async {
      final response = await dioNetworkManager.post(
        NetworkRequest(
          path: '/api/Storage/upload-url',
          data: {'fileName': fileName, 'contentType': contentType},
        ),
      );
      return response.data;
    },);
    return UploadUrlResponse.fromMap(response);
  }

  @override
  Future<void> uploadFileToStorage({
    required String uploadUrl,
    required File file,
    required String contentType,
    void Function(int sent, int total)? onProgress,
  }) async {
    // ── Dev/mock fallback ─────────────────────────────────────────────────
    // If backend returns a dummy URL (e.g. dummy-storage.local or localhost)
    // skip the actual upload so the UI flow can be tested without real S3.
    final uri = Uri.tryParse(uploadUrl);
    final host = uri?.host ?? '';
    final isMockUrl =
        host == 'dummy-storage.local' || host == 'localhost' || host == '127.0.0.1';

    if (isMockUrl) {
      debugPrint(
        '⚠️ Mock storage URL detected ($host) — skipping actual upload. '
        'Configure real S3/MinIO on the backend to enable uploads.',
      );
      // Simulate progress for UX
      onProgress?.call(1, 1);
      return;
    }

    // ── Real S3/MinIO upload ──────────────────────────────────────────────
    // Use a plain Dio (no auth headers) to upload directly to S3/MinIO
    final plainDio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 120),
      ),
    );

    try {
      final fileBytes = await file.readAsBytes();
      debugPrint('📤 Uploading ${fileBytes.length} bytes to S3...');

      await plainDio.put(
        uploadUrl,
        data: Stream.fromIterable([fileBytes]),
        options: Options(
          headers: {
            HttpHeaders.contentTypeHeader: contentType,
            HttpHeaders.contentLengthHeader: fileBytes.length,
          },
        ),
        onSendProgress: onProgress,
      );

      debugPrint('✅ File uploaded to storage successfully');
    } on DioException catch (e) {
      debugPrint('❌ S3 upload error: ${e.response?.statusCode} — ${e.message}');
      throw ServerException(message: 'Failed to upload file: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Upload error: $e');
    } finally {
      plainDio.close();
    }
  }
}
