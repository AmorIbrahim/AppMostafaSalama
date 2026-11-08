import 'package:flutter/material.dart';
import '../core/storage/storage_service.dart';

/// Manages Dark/Light mode state and persistence
class ThemeProvider extends ChangeNotifier {
  final StorageService _storageService;
  late ThemeMode _themeMode;

  ThemeProvider({required StorageService storageService})
      : _storageService = storageService {
    final modeStr = _storageService.getThemeMode();
    if (modeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (modeStr == 'system') {
      _themeMode = ThemeMode.system;
    } else {
      _themeMode = ThemeMode.dark;
    }
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    String modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.system) modeStr = 'system';
    await _storageService.setThemeMode(modeStr);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}

