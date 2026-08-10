import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_content.dart';
import '../services/api.dart';
import 'auth.dart';

class ContentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Prefixo da chave do marcador "já vi o mural até aqui".
  ///
  /// A chave leva o id da conta porque o marcador não é do aparelho: sem isso,
  /// quem entrasse depois no mesmo celular herdaria o "já vi" de outra pessoa e
  /// abriria o app com o selo apagado sobre publicações que nunca leu.
  static const String _lastSeenKeyPrefix = 'mural_last_seen_v1_';

  List<AppContent> _items = [];
  bool _isLoading = false;
  String? _error;
  String? _loadedToken;
  String? _sessionToken;

  /// Conta dona do marcador em memória, e a data da publicação mais recente que
  /// ela já viu. Só um carimbo de tempo — conteúdo do mural continua no cache.
  String? _seenAccount;
  DateTime? _lastSeenAt;

  List<AppContent> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Quantas publicações chegaram depois da última visita ao mural.
  ///
  /// Sem marcador (primeira abertura da conta neste aparelho) o mural inteiro é
  /// novidade, que é o que a primeira visita de fato é.
  int get unseenCount {
    final seenAt = _lastSeenAt;
    if (seenAt == null) return _items.length;
    return _items.where((item) => item.createdAt.isAfter(seenAt)).length;
  }

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

      // O token muda a cada login; a conta, não. Relê o marcador só quando é
      // outra pessoa — senão a leitura assíncrona apagaria, a cada reabertura
      // do app, o que a sessão anterior tinha acabado de marcar.
      final account = auth.user?.id;
      if (_seenAccount != account) {
        _seenAccount = account;
        _lastSeenAt = null;
        unawaited(_restoreLastSeen());
      }

      notifyListeners();
    }
  }

  /// Zera o estado em memória e o cache persistido do mural.
  ///
  /// O marcador de "já vi" fica gravado, guardado pelo id da conta: ele não é
  /// conteúdo, e apagá-lo no logout faria o selo de novidade reacender inteiro
  /// a cada volta.
  Future<void> clear() async {
    _items = [];
    _loadedToken = null;
    _error = null;
    _isLoading = false;
    _seenAccount = null;
    _lastSeenAt = null;
    notifyListeners();
    await _apiService.clearContentFeedCache();
  }

  /// Dá por vista a publicação mais recente que está na mão agora.
  Future<void> markSeen() async {
    if (_items.isEmpty) return;

    final newest = _items
        .map((item) => item.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    if (_lastSeenAt != null && !newest.isAfter(_lastSeenAt!)) return;

    _lastSeenAt = newest;
    notifyListeners();

    final account = _seenAccount;
    if (account == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        '$_lastSeenKeyPrefix$account',
        newest.toIso8601String(),
      );
    } catch (e) {
      // Selo aceso a mais é ruído; travar a leitura do mural seria pior.
      if (kDebugMode) debugPrint('Erro ao salvar o marcador do mural: $e');
    }
  }

  Future<void> _restoreLastSeen() async {
    final account = _seenAccount;
    if (account == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('$_lastSeenKeyPrefix$account');
      // A sessão pode ter trocado durante a leitura do disco.
      if (_seenAccount != account) return;

      _lastSeenAt = saved == null ? null : DateTime.tryParse(saved);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao ler o marcador do mural: $e');
    }
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
