import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _prefKey = 'selected_language_code';

  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  /// Loads saved language preference from SharedPreferences.
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null && ['en', 'te', 'hi'].contains(code)) {
        _currentLocale = Locale(code);
        notifyListeners();
      }
    } catch (_) {
      // Fallback to English default
    }
  }

  /// Updates language and persists selection to SharedPreferences.
  Future<void> setLanguage(String languageCode) async {
    if (!['en', 'te', 'hi'].contains(languageCode)) return;
    if (_currentLocale.languageCode == languageCode) return;

    _currentLocale = Locale(languageCode);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, languageCode);
    } catch (_) {
      // Ignore storage persistence failure
    }
  }
}

/// Global singleton instance for app-wide language switching
final languageService = LanguageService();
