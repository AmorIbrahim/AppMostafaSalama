import 'package:flutter/material.dart';
import '../storage/storage_service.dart';

/// Provider for dynamic language switching between Arabic (RTL) and English (LTR)
class AppLanguageProvider extends ChangeNotifier {
  final StorageService _storageService;
  late Locale _currentLocale;

  AppLanguageProvider({required StorageService storageService})
      : _storageService = storageService {
    final code = _storageService.getLocaleCode();
    _currentLocale = Locale(code);
  }

  Locale get currentLocale => _currentLocale;
  bool get isArabic => _currentLocale.languageCode == 'ar';

  Future<void> setLocale(Locale locale) async {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    await _storageService.setLocaleCode(locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleLanguage() async {
    final nextCode = _currentLocale.languageCode == 'ar' ? 'en' : 'ar';
    await setLocale(Locale(nextCode));
  }
}

