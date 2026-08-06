import 'dart:io';

import 'package:chateo_app/core/data/data_sources/storage_data_source.dart';
import 'package:chateo_app/core/utils/errors/failure.dart';
import 'package:dartz/dartz.dart';

/// Params for uploading an avatar image
class UploadAvatarParams {
  final File file;
  final void Function(int sent, int total)? onProgress;

  UploadAvatarParams({required this.file, this.onProgress});
}

/// Returns the fileKey (URL/identifier) of the uploaded image on success.
class UploadAvatarUseCase {
  final StorageDataSource storageDataSource;

  UploadAvatarUseCase({required this.storageDataSource});

  Future<Either<Failure, String>> call(UploadAvatarParams params) async {
    try {
      final path = params.file.path;
      final dotIndex = path.lastIndexOf('.');
      final extension = dotIndex >= 0 ? path.substring(dotIndex + 1) : 'jpg';
      final mimeType = _mimeFromExtension(extension);
      final fileName = 'avatar.$extension';

      // Step 1: Get presigned upload URL from backend
      final urlResponse = await storageDataSource.getUploadUrl(
        fileName: fileName,
        contentType: mimeType,
      );

      // Step 2: Upload file directly to S3/MinIO via presigned URL
      await storageDataSource.uploadFileToStorage(
        uploadUrl: urlResponse.uploadUrl,
        file: params.file,
        contentType: mimeType,
        onProgress: params.onProgress,
      );

      return Right(urlResponse.fileKey);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  String _mimeFromExtension(String ext) {
    switch (ext.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }
}
