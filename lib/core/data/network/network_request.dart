import 'package:dio/dio.dart';

class NetworkRequest {
  final String path;
  final dynamic data;
  final Map<String, dynamic>? queryParams;
  final Map<String, dynamic>? headers;
  final CancelToken? cancelToken;

  NetworkRequest({
    required this.path,
    this.data,
    this.queryParams,
    this.headers,
    this.cancelToken,
  });
}
