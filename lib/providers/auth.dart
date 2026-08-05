import 'dart:convert';
import 'package:flutter/material.dart';

import '../services/auth_storage.dart';
import '../services/api.dart';
import '../services/biometric_auth.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({BiometricAuth? biometrics})
    : _biometrics = biometrics ?? BiometricAuth();

  final ApiService _apiService = ApiService();
  final AuthStorage _authStorage = AuthStorage();
  final BiometricAuth _biometrics;

  LoginResponse? _user;
  bool _isGuest = false;
  bool _authAttempted = false;
  bool _isInitialPassword = false;
  bool _guidedTourCompleted = true;
  bool _biometricLocked = false;

  LoginResponse? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _isGuest;
  bool get authAttempted => _authAttempted;
  bool get isInitialPassword => _isInitialPassword;
  bool get guidedTourCompleted => _guidedTourCompleted;

  /// Existe sessão salva, mas a biometria não foi confirmada nesta abertura.
  ///
  /// A sessão continua no armazenamento seguro (o usuário pode reabrir o app e
  /// tentar de novo), só não é exposta.
  bool get biometricLocked => _biometricLocked;

  Future<void> login(String username, String password) async {
    final response = await _apiService.login(username, password);
    _user = response;
    _isGuest = false;
    _isInitialPassword = response.isInitialPassword;
    _guidedTourCompleted = response.guidedTourCompleted;
    _biometricLocked = false;

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
    _biometricLocked = false;

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

      // Gate biométrico antes de expor a sessão: com a preferência ligada, sem
      // biometria confirmada não há sessão restaurada — cai na tela de login,
      // onde a senha continua funcionando. Falhar aberto aqui tornaria o toggle
      // decorativo de novo.
      if (await _biometrics.isEnabled() &&
          !await _biometrics.confirmToUnlock()) {
        _biometricLocked = true;
        _user = null;
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
    _biometricLocked = false;
    await _authStorage.clearSession();

    notifyListeners();
  }
}
