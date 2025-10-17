import 'package:flutter/material.dart';

enum ThemeModeOption { light, dark }

class ThemeProvider with ChangeNotifier {
  ThemeModeOption _themeMode = ThemeModeOption.light;

  ThemeMode get currentTheme =>
      _themeMode == ThemeModeOption.light ? ThemeMode.light : ThemeMode.dark;

  bool get isDarkMode => _themeMode == ThemeModeOption.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeModeOption.light
        ? ThemeModeOption.dark
        : ThemeModeOption.light;

    notifyListeners();
  }
}
