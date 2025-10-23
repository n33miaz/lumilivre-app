import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption { system, light, dark }

class ThemeProvider with ChangeNotifier {
  ThemeOption _themeOption = ThemeOption.system;

  ThemeProvider() {
    _loadThemePreference();
  }

  ThemeOption get themeOption => _themeOption;

  ThemeMode get currentTheme {
    switch (_themeOption) {
      case ThemeOption.light:
        return ThemeMode.light;
      case ThemeOption.dark:
        return ThemeMode.dark;
      case ThemeOption.system:
      default:
        return ThemeMode.system;
    }
  }

  bool get isDarkMode {
    if (_themeOption == ThemeOption.system) {
      return SchedulerBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeOption == ThemeOption.dark;
  }

  void setTheme(ThemeOption option) {
    if (_themeOption != option) {
      _themeOption = option;
      _saveThemePreference(option);
      notifyListeners();
    }
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex =
        prefs.getInt('themeOption') ?? 0; 
    _themeOption = ThemeOption.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveThemePreference(ThemeOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeOption', option.index);
  }
}
