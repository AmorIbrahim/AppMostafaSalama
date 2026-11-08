import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/app_exception.dart';
import '../storage/storage_service.dart';
import 'auth_interceptor.dart';
import '../../models/order_model.dart';

/// Centralized HTTP client managing all Mostafa Salama API interactions
class ApiClient {
  late final Dio _dio;
  final StorageService _storageService;
  void Function()? onSessionExpired;

  ApiClient({
    required StorageService storageService,
    this.onSessionExpired,
  }) : _storageService = storageService {
    final baseUrl = _storageService.getBaseUrl();
    _dio = Dio(
      BaseOptions(
        baseUrl: '$baseUrl${ApiConstants.apiPrefix}',
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        validateStatus: (status) => status != null && status >= 200 && status < 300,
      ),
    );

    _dio.interceptors.add(
      AuthInterceptor(
        storageService: _storageService,
        onSessionExpired: () {
          if (onSessionExpired != null) {
            onSessionExpired!();
          }
        },
      ),
    );
  }

  /// Update the base URL dynamically (e.g., switching from production to local dev server)
  void updateBaseUrl(String newUrl) {
    _dio.options.baseUrl = '$newUrl${ApiConstants.apiPrefix}';
  }

  // -------------------------------------------------------------
  // 1. Authentication Endpoints
  // -------------------------------------------------------------

  /// POST /api/delivery/login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String deviceName = 'Flutter Delivery Mobile',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email.trim(),
          'password': password,
          'device_name': deviceName,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    } catch (e) {
      throw AppException(
        message: e.toString(),
        messageAr: 'فشل تسجيل الدخول. يرجى المحاولة مرة أخرى.',
      );
    }
  }

  /// POST /api/delivery/logout
  Future<bool> logout() async {
    try {
      final response = await _dio.post(ApiConstants.logout);
      return response.statusCode == 200;
    } on DioException catch (e) {
      // Even if network fails on logout, we clear local tokens
      throw AppException.fromDioException(e);
    } catch (_) {
      return true;
    }
  }

  /// GET /api/delivery/me
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  /// POST /api/delivery/change-password
  Future<Map<String, dynamic>> changePassword({
    String? currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      };
      if (currentPassword != null && currentPassword.isNotEmpty) {
        data['current_password'] = currentPassword;
      }

      final response = await _dio.post(
        ApiConstants.changePassword,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  // -------------------------------------------------------------
  // 2. Orders Endpoints
  // -------------------------------------------------------------

  /// GET /api/delivery/orders
  Future<Map<String, dynamic>> getOrders({
    String status = 'active',
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.orders,
        queryParameters: {
          'status': status,
          'page': page,
          'per_page': perPage,
        },
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  /// GET /api/delivery/orders/{id}
  Future<OrderModel> getOrderDetails(int orderId) async {
    try {
      final response = await _dio.get(ApiConstants.orderDetails(orderId));
      final data = response.data as Map<String, dynamic>;
      final orderJson = data['data']?['order'] ?? data['data'] ?? data;
      return OrderModel.fromJson(orderJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  /// POST /api/delivery/orders/{id}/accept
  Future<OrderModel> acceptOrder(int orderId) async {
    try {
      final response = await _dio.post(ApiConstants.acceptOrder(orderId));
      final data = response.data as Map<String, dynamic>;
      final orderJson = data['data']?['order'] ?? data['data'] ?? data;
      return OrderModel.fromJson(orderJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  /// POST /api/delivery/orders/{id}/start
  Future<OrderModel> startDelivery(int orderId) async {
    try {
      final response = await _dio.post(ApiConstants.startDelivery(orderId));
      final data = response.data as Map<String, dynamic>;
      final orderJson = data['data']?['order'] ?? data['data'] ?? data;
      return OrderModel.fromJson(orderJson as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  /// POST /api/delivery/orders/confirm-qr
  /// Accepts either raw HMAC token or full scanned URL, optional orderId for safety verification
  Future<Map<String, dynamic>> confirmQrDelivery({
    required String qrToken,
    int? orderId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'qr_token': qrToken.trim(),
      };
      if (orderId != null && orderId > 0) {
        data['order_id'] = orderId;
      }

      final response = await _dio.post(
        ApiConstants.confirmQr,
        data: data,
      );
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw AppException.fromDioException(e);
    }
  }

  // -------------------------------------------------------------
  // 3. Push Notification / FCM Device Token Endpoints
  // -------------------------------------------------------------

  /// POST /api/delivery/device-token
  Future<bool> registerDeviceToken({
    required String fcmToken,
    String platform = 'android',
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.deviceToken,
        data: {
          'fcm_token': fcmToken.trim(),
          'platform': platform,
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// DELETE /api/delivery/device-token
  Future<bool> unregisterDeviceToken({
    required String fcmToken,
  }) async {
    try {
      final response = await _dio.delete(
        ApiConstants.deviceToken,
        data: {
          'fcm_token': fcmToken.trim(),
        },
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
