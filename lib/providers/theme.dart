import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeOption { system, light, dark }

class ThemeProvider with ChangeNotifier, WidgetsBindingObserver {
  ThemeOption _themeOption = ThemeOption.light;

  bool _isSystemDark =
      SchedulerBinding.instance.platformDispatcher.platformBrightness ==
      Brightness.dark;

  ThemeProvider() {
    _loadThemePreference();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    final newBrightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    final isNowDark = newBrightness == Brightness.dark;

    if (_isSystemDark != isNowDark) {
      _isSystemDark = isNowDark;
      if (_themeOption == ThemeOption.system) {
        notifyListeners();
      }
    }
  }        

  ThemeOption get themeOption => _themeOption;

  ThemeMode get currentTheme {
    switch (_themeOption) {
      case ThemeOption.light:
        return ThemeMode.light;
      case ThemeOption.dark:
        return ThemeMode.dark;
      case ThemeOption.system:
        return _isSystemDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  bool get isDarkMode {
    if (_themeOption == ThemeOption.system) {
      return _isSystemDark;
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
    final themeIndex = prefs.getInt('themeOption') ?? ThemeOption.light.index;
    _themeOption = ThemeOption.values[themeIndex];
    notifyListeners();
  }

  Future<void> _saveThemePreference(ThemeOption option) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeOption', option.index);
  }
}
