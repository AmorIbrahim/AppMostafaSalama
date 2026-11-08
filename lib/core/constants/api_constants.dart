/// API Endpoints and configuration for Mostafa Salama Delivery Driver Application
class ApiConstants {
  // Default Base URL (Production)
  static const String defaultProductionUrl = 'https://mostafasalama.com';
  
  // Local emulator URLs for development / testing
  static const String androidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String localHostUrl = 'http://127.0.0.1:8000';

  // API Prefix
  static const String apiPrefix = '/api/delivery';

  // Timeout settings
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
  static const Duration sendTimeout = Duration(seconds: 15);

  // Authentication Endpoints
  static const String login = '/login';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String changePassword = '/change-password';

  // Order Management Endpoints
  static const String orders = '/orders';
  static String orderDetails(int id) => '/orders/$id';
  static String acceptOrder(int id) => '/orders/$id/accept';
  static String startDelivery(int id) => '/orders/$id/start';
  static const String confirmQr = '/orders/confirm-qr';

  // Standard API Error Codes
  static const String errUnauthenticated = 'UNAUTHENTICATED';
  static const String errInvalidCredentials = 'INVALID_CREDENTIALS';
  static const String errNotADriver = 'NOT_A_DRIVER';
  static const String errAccountDeactivated = 'ACCOUNT_DEACTIVATED';
  static const String errForbidden = 'FORBIDDEN';
  static const String errNotFound = 'NOT_FOUND';
  static const String errInvalidToken = 'INVALID_TOKEN';
  static const String errInvalidStatus = 'INVALID_STATUS';
  static const String errUnassignedDriver = 'UNASSIGNED_DRIVER';
  static const String errAlreadyDelivered = 'ALREADY_DELIVERED';
  static const String errValidationError = 'VALIDATION_ERROR';
}

