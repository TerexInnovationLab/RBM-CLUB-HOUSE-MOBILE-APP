import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/api_endpoints.dart';
import 'secure_storage_service.dart';

/// Determines the current environment (`dev` or `prod`).
String currentEnvironment() =>
    const String.fromEnvironment('ENV', defaultValue: 'dev').toLowerCase();

/// Provides the API base URL by environment.
String apiBaseUrl() {
  final env = currentEnvironment();
  if (env == 'prod') {
    return const String.fromEnvironment('API_BASE_URL_PROD', defaultValue: '');
  }
  return const String.fromEnvironment('API_BASE_URL_DEV', defaultValue: '');
}

/// Typed API exception.
class ApiException implements Exception {
  /// Creates an API exception.
  ApiException(this.message, {this.statusCode});

  /// Human-readable message.
  final String message;

  /// HTTP status code (if available).
  final int? statusCode;

  @override
  String toString() => 'ApiException(statusCode: $statusCode, message: $message)';
}

/// Central Dio client with token attachment and refresh handling.
class ApiService {
  /// Creates an API service.
  ApiService(this._storage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl(),
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 20),
        headers: const {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final shouldAttemptRefresh = _shouldAttemptRefresh(error);
          if (!shouldAttemptRefresh) {
            handler.next(error);
            return;
          }

          try {
            await _refreshTokens();
            final response = await _retry(error.requestOptions);
            handler.resolve(response);
          } catch (e) {
            handler.next(error);
          }
        },
      ),
    );
  }

  final SecureStorageService _storage;
  late final Dio _dio;
  bool _refreshing = false;
  Completer<void>? _refreshCompleter;

  /// Exposes the configured Dio instance to repositories.
  Dio get dio => _dio;

  bool _shouldAttemptRefresh(DioException error) {
    if (error.response?.statusCode != 401) return false;
    final path = error.requestOptions.path;
    if (path == ApiEndpoints.authRefresh) return false;
    return true;
  }

  Future<void> _refreshTokens() async {
    if (_refreshing) {
      await _refreshCompleter?.future;
      return;
    }

    _refreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw ApiException('Missing refresh token.');
      }

      final refreshDio = Dio(BaseOptions(baseUrl: _dio.options.baseUrl));
      final response = await refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.authRefresh,
        data: {'refreshToken': refreshToken},
      );

      final data = response.data ?? const {};
      final newAccess = data['accessToken'] as String?;
      final newRefresh = data['refreshToken'] as String?;
      if (newAccess == null || newRefresh == null) {
        throw ApiException('Invalid refresh response.', statusCode: response.statusCode);
      }

      await _storage.writeTokens(accessToken: newAccess, refreshToken: newRefresh);
    } on DioException catch (e) {
      debugPrint('Token refresh failed: ${e.message}');
      rethrow;
    } finally {
      _refreshing = false;
      _refreshCompleter?.complete();
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      validateStatus: requestOptions.validateStatus,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      followRedirects: requestOptions.followRedirects,
      maxRedirects: requestOptions.maxRedirects,
      requestEncoder: requestOptions.requestEncoder,
      responseDecoder: requestOptions.responseDecoder,
      listFormat: requestOptions.listFormat,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }
}

/// Provider for API service.
final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.read(secureStorageServiceProvider);
  return ApiService(storage);
});

