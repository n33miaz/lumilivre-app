import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_content.dart';
import '../services/api.dart';
import 'auth.dart';

class ContentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<AppContent> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _loadedToken;
  String? _sessionToken;

  List<AppContent> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Acompanha a sessão: no logout (ou troca de usuário) descarta o mural em
  /// memória e o cache local — o feed é segmentado por público e não pode
  /// vazar entre contas no mesmo dispositivo.
  void syncWithAuth(AuthProvider auth) {
    final token = auth.user?.token;

    if (!auth.isAuthenticated || token == null || token.isEmpty) {
      if (_sessionToken != null || _items.isNotEmpty || _loadedToken != null) {
        _sessionToken = null;
        unawaited(clear());
      }
      return;
    }

    if (_sessionToken != token) {
      _sessionToken = token;
      _items = [];
      _loadedToken = null;
      _error = null;
      notifyListeners();
    }
  }

  /// Zera o estado em memória e o cache persistido do mural.
  Future<void> clear() async {
    _items = [];
    _loadedToken = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
    await _apiService.clearContentFeedCache();
  }

  /// Carrega o mural em modo stale-while-revalidate:
  /// 1. Emite o cache local imediatamente (se existir).
  /// 2. Revalida contra a API em seguida.
  ///
  /// Ignora chamadas redundantes: se já houver um carregamento em andamento,
  /// ou se o feed já foi carregado para o mesmo [token], nada acontece
  /// (a menos que [force] seja `true`, usado pelo pull-to-refresh).
  Future<void> load(String token, {bool force = false}) async {
    if (token.isEmpty) {
      return;
    }
    if (_isLoading) {
      return;
    }
    if (!force && _loadedToken == token && _items.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    // --- STALE: cache local primeiro ---
    if (!force) {
      try {
        final cached = await _apiService.getContentFeedLocal();
        if (cached.isNotEmpty) {
          _items = cached;
          notifyListeners();
        }
      } catch (e) {
        if (kDebugMode) debugPrint('Erro ao ler cache do mural: $e');
      }
    }

    // --- REVALIDATE: rede ---
    try {
      _items = await _apiService.fetchAndSaveContentFeed(token: token);
      _loadedToken = token;
      _error = null;
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao carregar o mural: $e');
      if (_items.isEmpty) {
        _error = e.toString();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Força uma nova busca na API (pull-to-refresh).
  Future<void> refresh(String token) => load(token, force: true);
}
