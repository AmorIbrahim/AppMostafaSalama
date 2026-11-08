import 'package:dio/dio.dart';
import '../storage/storage_service.dart';
import '../constants/api_constants.dart';

/// Interceptor to automatically attach Sanctum Bearer token and handle session invalidation
class AuthInterceptor extends QueuedInterceptor {
  final StorageService _storageService;
  final void Function()? onSessionExpired;

  AuthInterceptor({
    required StorageService storageService,
    this.onSessionExpired,
  }) : _storageService = storageService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Attach default JSON headers
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    // Attach Sanctum Bearer token if present
    final token = await _storageService.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final data = err.response?.data;
    String? errorCode;
    if (data is Map<String, dynamic>) {
      errorCode = data['error_code']?.toString();
    }

    // If 401 or Account Deactivated, clear local token and trigger session expiry
    if (statusCode == 401 ||
        errorCode == ApiConstants.errAccountDeactivated ||
        errorCode == ApiConstants.errUnauthenticated) {
      await _storageService.clearAuthSession();
      if (onSessionExpired != null) {
        onSessionExpired!();
      }
    }

    return handler.next(err);
  }
}

