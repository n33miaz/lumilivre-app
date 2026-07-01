import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/library_settings.dart';
import '../services/api.dart';
import 'auth.dart';

typedef SettingsLoader = Future<LibrarySettings> Function(String token);

class SettingsProvider with ChangeNotifier {
  SettingsProvider({SettingsLoader? loadSettings})
    : _loadSettings = loadSettings ?? ApiService().getSettings;

  final SettingsLoader _loadSettings;

  LibrarySettings _settings = LibrarySettings.school();
  bool _isLoading = false;
  String? _loadedToken;

  LibrarySettings get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isStandard => _settings.isStandard;
  bool get showAcademicFields => _settings.features.academicFields;
  bool get showRanking => _settings.features.ranking;
  bool get showThesis => _settings.features.thesis;

  void syncWithAuth(AuthProvider auth) {
    final token = auth.user?.token;

    if (!auth.isAuthenticated || token == null || token.isEmpty) {
      if (_loadedToken != null || _settings.isStandard) {
        _loadedToken = null;
        _settings = LibrarySettings.school();
        notifyListeners();
      }
      return;
    }

    if (_loadedToken == token || _isLoading) {
      return;
    }

    unawaited(load(token));
  }

  Future<void> load(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _loadSettings(token);
      _loadedToken = token;
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao carregar configuracoes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
