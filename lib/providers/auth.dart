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
  bool _guidedTourCompleted = true;

  LoginResponse? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _isGuest;
  bool get authAttempted => _authAttempted;
  bool get isInitialPassword => _isInitialPassword;
  bool get guidedTourCompleted => _guidedTourCompleted;

  Future<void> login(String username, String password) async {
    final response = await _apiService.login(username, password);
    _user = response;
    _isGuest = false;
    _isInitialPassword = response.isInitialPassword;
    _guidedTourCompleted = response.guidedTourCompleted;

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
    _guidedTourCompleted = true;

    notifyListeners();
  }

  Future<void> completeInitialPasswordChange() async {
    _isInitialPassword = false;
    if (_user != null) {
      _user = LoginResponse(
        id: _user!.id,
        email: _user!.email,
        role: _user!.role,
        readerRegistrationNumber: _user!.readerRegistrationNumber,
        token: _user!.token,
        isInitialPassword: false,
        guidedTourCompleted: _user!.guidedTourCompleted,
      );
      await _authStorage.saveSession(
        token: _user!.token,
        userData: jsonEncode(_user),
      );
    }
    notifyListeners();
  }

  /// Marca o tour guiado como concluído localmente e regrava a sessão.
  Future<void> completeTour() async {
    _guidedTourCompleted = true;
    if (_user != null) {
      _user = LoginResponse(
        id: _user!.id,
        email: _user!.email,
        role: _user!.role,
        readerRegistrationNumber: _user!.readerRegistrationNumber,
        token: _user!.token,
        isInitialPassword: _user!.isInitialPassword,
        guidedTourCompleted: true,
      );
      await _authStorage.saveSession(
        token: _user!.token,
        userData: jsonEncode(_user),
      );
    }
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    await _authStorage.migrateLegacySession();

    try {
      final token = await _authStorage.getToken();
      final userDataString = await _authStorage.getUserData();

      if (token == null || userDataString == null) {
        _authAttempted = true;
        notifyListeners();
        return;
      }

      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      _user = LoginResponse.fromJson({...userData, 'token': token});
      _isInitialPassword = _user?.isInitialPassword ?? false;
      _guidedTourCompleted = _user?.guidedTourCompleted ?? true;
    } catch (_) {
      await _authStorage.clearSession();
      _user = null;
      _isInitialPassword = false;
      _guidedTourCompleted = true;
    }

    _authAttempted = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isGuest = false;
    _isInitialPassword = false;
    _guidedTourCompleted = true;
    await _authStorage.clearSession();

    notifyListeners();
  }
}
