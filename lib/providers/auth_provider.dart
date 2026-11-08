import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/storage/storage_service.dart';
import '../core/errors/app_exception.dart';
import '../models/driver_model.dart';
import '../models/delivery_stats_model.dart';
import '../services/notification_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, mustChangePassword }

/// Authentication Provider managing driver session, login, password updates, and logout
class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient;
  final StorageService _storageService;

  AuthStatus _status = AuthStatus.uninitialized;
  DriverModel? _driver;
  DeliveryStatsModel? _stats;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required ApiClient apiClient,
    required StorageService storageService,
  })  : _apiClient = apiClient,
        _storageService = storageService {
    // Listen for 401 or account deactivation events from API client
    _apiClient.onSessionExpired = _handleSessionExpired;
  }

  AuthStatus get status => _status;
  DriverModel? get driver => _driver;
  DeliveryStatsModel? get stats => _stats;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get mustChangePassword => _status == AuthStatus.mustChangePassword;

  /// Initialize and verify saved session on app startup
  Future<void> initAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final savedToken = await _storageService.getToken();
      final cachedDriver = _storageService.getDriver();

      if (savedToken != null && savedToken.isNotEmpty) {
        _token = savedToken;
        _driver = cachedDriver;

        // Verify token with backend /api/delivery/me
        try {
          final meResponse = await _apiClient.getMe();
          if (meResponse['data'] != null) {
            final driverData = meResponse['data']['driver'];
            if (driverData != null) {
              _driver = DriverModel.fromJson(driverData as Map<String, dynamic>);
              await _storageService.saveDriver(_driver!);
            }

            final statsData = meResponse['data']['stats'];
            if (statsData != null) {
              _stats = DeliveryStatsModel.fromJson(statsData as Map<String, dynamic>);
            }

            if (_driver?.mustChangePassword == true) {
              _status = AuthStatus.mustChangePassword;
            } else if (_driver?.isActive == false) {
              await _storageService.clearAuthSession();
              _status = AuthStatus.unauthenticated;
              _errorMessage = 'Your account has been deactivated by management.';
            } else {
              _status = AuthStatus.authenticated;
            }
          } else {
            _status = AuthStatus.authenticated;
          }
        } on AppException catch (e) {
          // If token expired or deactivated, clear
          if (e.statusCode == 401 || e.statusCode == 403) {
            await _storageService.clearAuthSession();
            _status = AuthStatus.unauthenticated;
            _errorMessage = e.message;
          } else {
            // If offline, trust cached session for seamless driver experience
            _status = AuthStatus.authenticated;
          }
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }

      if (_status == AuthStatus.authenticated) {
        NotificationService.registerToken(_apiClient);
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Driver Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.login(
        email: email,
        password: password,
      );

      final data = response['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw AppException(
          message: 'Malformed login response from server.',
          messageAr: 'استجابة غير صحيحة من الخادم.',
        );
      }

      final tokenStr = data['token']?.toString() ?? '';
      _token = tokenStr;
      await _storageService.saveToken(tokenStr);

      final driverJson = data['driver'] as Map<String, dynamic>?;
      if (driverJson != null) {
        _driver = DriverModel.fromJson(driverJson);
        await _storageService.saveDriver(_driver!);
      }

      final bool mustChange = data['must_change_password'] == true ||
          _driver?.mustChangePassword == true;

      if (_driver != null && !_driver!.isActive) {
        await _storageService.clearAuthSession();
        _status = AuthStatus.unauthenticated;
        _errorMessage = 'This driver account is deactivated. Contact management.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (mustChange) {
        _status = AuthStatus.mustChangePassword;
      } else {
        _status = AuthStatus.authenticated;
        NotificationService.registerToken(_apiClient);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred during login.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Change Password (required for first login or from profile)
  Future<bool> changePassword({
    String? currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiClient.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      // Password successfully updated, remove mustChangePassword restriction
      if (_driver != null) {
        _driver = _driver!.copyWith(mustChangePassword: false);
        await _storageService.saveDriver(_driver!);
      }
      _status = AuthStatus.authenticated;
      NotificationService.registerToken(_apiClient);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _errorMessage = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Driver Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await NotificationService.unregisterToken(_apiClient);
    } catch (_) {}

    try {
      await _apiClient.logout();
    } catch (_) {
      // Ignored: clear locally even if network fails
    }

    await _storageService.clearAuthSession();
    _token = null;
    _driver = null;
    _stats = null;
    _status = AuthStatus.unauthenticated;
    _isLoading = false;
    notifyListeners();
  }

  void _handleSessionExpired() {
    _token = null;
    _driver = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = 'Session expired. Please sign in again.';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

