import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/api.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthStorage _authStorage = AuthStorage();

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

    await _authStorage.saveSession(
      token: response.token,
      userData: jsonEncode(response),
    );

    notifyListeners();
  }

  void loginAsGuest() {
    _user = null;
    _isGuest = true;
    _isInitialPassword = false;

    notifyListeners();
  }

  void completeInitialPasswordChange() {
    _isInitialPassword = false;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final token = await _authStorage.getToken();
    final userDataString = await _authStorage.getUserData();

    if (token == null || userDataString == null) {
      _authAttempted = true;
      notifyListeners();
      return;
    }

    final userData = jsonDecode(userDataString);
    _user = LoginResponse.fromJson(userData);
    _isInitialPassword = _user?.isInitialPassword ?? false;

    _authAttempted = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isGuest = false;
    _isInitialPassword = false;
    await _authStorage.clearSession();

    notifyListeners();
  }
}
