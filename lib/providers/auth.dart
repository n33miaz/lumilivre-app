import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  LoginResponse? _user;
  bool _isGuest = false;
  bool _authAttempted = false;

  LoginResponse? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isGuest => _isGuest;
  bool get authAttempted => _authAttempted;

  Future<void> login(String username, String password) async {
    final response = await _apiService.login(username, password);
    _user = response;
    _isGuest = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', response.token);
    
    notifyListeners();
  }

  void loginAsGuest() {
    _user = null;
    _isGuest = true;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('authToken')) {
      _authAttempted = true;
      notifyListeners();
      return;
    }
    
    final token = prefs.getString('authToken');
    // TODO: endpoint para validar o token
    print('Token encontrado: $token. Auto-login (simulado).');
    
    _authAttempted = true;
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _isGuest = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    notifyListeners();
  }
}