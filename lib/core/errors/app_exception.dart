import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

/// Structured application exception with user-friendly Arabic & English messaging
class AppException implements Exception {
  final String message;
  final String? messageAr;
  final String? errorCode;
  final int? statusCode;
  final dynamic details;

  AppException({
    required this.message,
    this.messageAr,
    this.errorCode,
    this.statusCode,
    this.details,
  });

  String localizedMessage(bool isArabic) {
    if (isArabic && messageAr != null && messageAr!.isNotEmpty) {
      return messageAr!;
    }
    return message;
  }

  factory AppException.fromDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return AppException(
        message: 'Connection timed out. Please check your internet connection.',
        messageAr: 'انتهت مهلة الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت.',
        errorCode: 'TIMEOUT',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return AppException(
        message: 'Unable to connect to server. Please verify your connection.',
        messageAr: 'تعذر الاتصال بالخادم. يرجى التأكد من اتصال الهاتف بالإنترنت.',
        errorCode: 'NO_CONNECTION',
      );
    }

    if (e.response != null) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      String serverMessage = 'An unexpected error occurred.';
      String? errorCode;
      String? messageAr;

      if (data is Map<String, dynamic>) {
        serverMessage = data['message']?.toString() ?? serverMessage;
        errorCode = data['error_code']?.toString();
      }

      // Map specific backend error codes to clear Arabic/English messages
      switch (errorCode) {
        case ApiConstants.errInvalidCredentials:
          messageAr = 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
          break;
        case ApiConstants.errNotADriver:
          messageAr = 'هذا الحساب ليس لديه صلاحية سائق توصيل.';
          break;
        case ApiConstants.errAccountDeactivated:
          messageAr = 'تم تعطيل هذا الحساب من قبل إدارة المطعم.';
          break;
        case ApiConstants.errUnauthenticated:
          messageAr = 'انتهت الجلسة. يرجى تسجيل الدخول مجدداً.';
          break;
        case ApiConstants.errForbidden:
          messageAr = 'ليس لديك صلاحية للوصول إلى هذا الطلب.';
          break;
        case ApiConstants.errUnassignedDriver:
          messageAr = 'هذا الطلب غير مخصص لك.';
          break;
        case ApiConstants.errAlreadyDelivered:
          messageAr = 'تم تأكيد تسليم هذا الطلب مسبقاً.';
          break;
        case ApiConstants.errInvalidToken:
          messageAr = 'رمز الاستجابة السريعة (QR) غير صالح أو منتهي الصلاحية.';
          break;
        case ApiConstants.errInvalidStatus:
          messageAr = 'لا يمكن تغيير حالة الطلب في وضعه الحالي.';
          break;
        case ApiConstants.errNotFound:
          messageAr = 'الطلب أو المورد المطلوب غير موجود.';
          break;
      }

      if (messageAr == null) {
        if (statusCode == 401) {
          messageAr = 'بيانات الاعتماد غير صالحة أو انتهت الجلسة.';
        } else if (statusCode == 403) {
          messageAr = 'الوصول غير مصرح به.';
        } else if (statusCode == 404) {
          messageAr = 'الطلب غير موجود.';
        } else if (statusCode == 409) {
          messageAr = 'تعارض في العملية. ربما تم تحديث الطلب مسبقاً.';
        } else if (statusCode == 422) {
          messageAr = 'بيانات الإدخال غير صالحة.';
        } else if (statusCode != null && statusCode >= 500) {
          messageAr = 'حدث خطأ في خادم المطعم. يرجى المحاولة لاحقاً.';
        }
      }

      return AppException(
        message: serverMessage,
        messageAr: messageAr,
        errorCode: errorCode,
        statusCode: statusCode,
        details: data,
      );
    }

    return AppException(
      message: e.message ?? 'An unknown network error occurred.',
      messageAr: 'حدث خطأ غير متوقع في الشبكة.',
    );
  }

  @override
  String toString() => message;
}

