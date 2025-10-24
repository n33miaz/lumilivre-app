import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  LoginResponse? _user;
  bool _isGuest = false;
  bool _authAttempted = false;
  bool _isInitialPassword = false;

  LoginResponse? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _isGuest;
  bool get authAttempted => _authAttempted;
  bool get isInitialPassword => _isInitialPassword;

  Future<void> login(String username, String password) async {
    final response = await _apiService.login(username, password);
    _user = response;
    _isGuest = false;
    _isInitialPassword = response.isInitialPassword;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', response.token);
    await prefs.setString('userData', jsonEncode(response));

    notifyListeners();
  }

  void loginAsGuest() {
    _user = null;
    _isGuest = true;
    _isInitialPassword = false;

    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken') || !prefs.containsKey('userData')) {
      _authAttempted = true;
      notifyListeners();
      return;
    }

    // TODO resolvido (por enquanto, confiamos nos dados salvos)
    final userDataString = prefs.getString('userData');
    if (userDataString != null) {
      final userData = jsonDecode(userDataString);
      _user = LoginResponse.fromJson(userData);
      _isInitialPassword = _user?.isInitialPassword ?? false;
    }

    _authAttempted = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isGuest = false;
    _isInitialPassword = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    await prefs.remove('userData');

    notifyListeners();
  }
}
