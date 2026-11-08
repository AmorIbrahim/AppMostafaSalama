import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../models/driver_model.dart';

/// Secure & persistent storage service for authentication credentials and app preferences
class StorageService {
  static const String _keyToken = 'ms_auth_token';
  static const String _keyDriver = 'ms_driver_profile';
  static const String _keyLocale = 'ms_locale_code';
  static const String _keyThemeMode = 'ms_theme_mode';
  static const String _keyBaseUrl = 'ms_base_url';

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences? _prefs;
  final Map<String, String> _memoryFallback = {};

  StorageService._({
    required FlutterSecureStorage secureStorage,
    SharedPreferences? prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  static Future<StorageService> init() async {
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    );

    SharedPreferences? prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (_) {
      // Graceful fallback for hot-reload or unlinked platform channels
      prefs = null;
    }

    return StorageService._(secureStorage: secureStorage, prefs: prefs);
  }

  // --- Auth Token Management ---
  Future<void> saveToken(String token) async {
    try {
      await _secureStorage.write(key: _keyToken, value: token);
    } catch (_) {
      _memoryFallback[_keyToken] = token;
    }
  }

  Future<String?> getToken() async {
    try {
      return await _secureStorage.read(key: _keyToken);
    } catch (_) {
      return _memoryFallback[_keyToken];
    }
  }

  Future<void> deleteToken() async {
    try {
      await _secureStorage.delete(key: _keyToken);
    } catch (_) {
      _memoryFallback.remove(_keyToken);
    }
  }

  // --- Driver Profile Management ---
  Future<void> saveDriver(DriverModel driver) async {
    final jsonStr = jsonEncode(driver.toJson());
    if (_prefs != null) {
      await _prefs.setString(_keyDriver, jsonStr);
    } else {
      _memoryFallback[_keyDriver] = jsonStr;
    }
  }

  DriverModel? getDriver() {
    final jsonStr = _prefs?.getString(_keyDriver) ?? _memoryFallback[_keyDriver];
    if (jsonStr == null || jsonStr.isEmpty) return null;
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return DriverModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteDriver() async {
    if (_prefs != null) {
      await _prefs.remove(_keyDriver);
    } else {
      _memoryFallback.remove(_keyDriver);
    }
  }

  // --- Clear Entire Session ---
  Future<void> clearAuthSession() async {
    await deleteToken();
    await deleteDriver();
  }

  // --- Preferences: Language Locale ---
  String getLocaleCode() {
    return _prefs?.getString(_keyLocale) ?? _memoryFallback[_keyLocale] ?? 'ar';
  }

  Future<void> setLocaleCode(String code) async {
    if (_prefs != null) {
      await _prefs.setString(_keyLocale, code);
    } else {
      _memoryFallback[_keyLocale] = code;
    }
  }

  // --- Preferences: Theme Mode ---
  String getThemeMode() {
    return _prefs?.getString(_keyThemeMode) ?? _memoryFallback[_keyThemeMode] ?? 'dark';
  }

  Future<void> setThemeMode(String mode) async {
    if (_prefs != null) {
      await _prefs.setString(_keyThemeMode, mode);
    } else {
      _memoryFallback[_keyThemeMode] = mode;
    }
  }

  // --- Preferences: Backend Base URL ---
  String getBaseUrl() {
    return _prefs?.getString(_keyBaseUrl) ?? _memoryFallback[_keyBaseUrl] ?? ApiConstants.defaultProductionUrl;
  }

  Future<void> setBaseUrl(String url) async {
    if (_prefs != null) {
      await _prefs.setString(_keyBaseUrl, url);
    } else {
      _memoryFallback[_keyBaseUrl] = url;
    }
  }
}

