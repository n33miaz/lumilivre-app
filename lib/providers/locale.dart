import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const _storageKey = 'app_locale';

  Locale _locale = const Locale('pt', 'BR');

  Locale get locale => _locale;

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final parts = raw.split(RegExp('[-_]'));
      _locale = parts.length >= 2
          ? Locale(parts[0], parts[1])
          : Locale(parts.first);
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, locale.toLanguageTag());
    notifyListeners();
  }
}
