import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_content.dart';
import '../utils/constants.dart';
import 'request_context.dart';

class ContentApi {
  ContentApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _feedCacheKeyPrefix = 'content_feed_cache_v1_';

  /// Lê o mural salvo localmente (stale) sem tocar na rede.
  Future<List<AppContent>> getFeedLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = await RequestContext.currentLocaleTag();
      final jsonString = prefs.getString('$_feedCacheKeyPrefix$locale');

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> data = json.decode(jsonString);
        return _parseFeedJson(data);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao ler cache do mural: $e');
    }
    return [];
  }

  /// Remove o mural salvo localmente (todos os locales). Chamado no logout
  /// para não vazar conteúdo segmentado entre contas no mesmo dispositivo.
  Future<void> clearFeedCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs
          .getKeys()
          .where((k) => k.startsWith(_feedCacheKeyPrefix))
          .toList();
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao limpar cache do mural: $e');
    }
  }

  /// Busca o mural na API, persiste o corpo bruto em cache e devolve a lista.
  Future<List<AppContent>> fetchAndSaveFeed({required String token}) async {
    final url = Uri.parse('$apiBaseUrl/api/contents/feed');
    final prefs = await SharedPreferences.getInstance();
    final locale = await RequestContext.currentLocaleTag();

    try {
      final response = await _client
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        if (body.isNotEmpty) {
          await prefs.setString('$_feedCacheKeyPrefix$locale', body);
          final List<dynamic> data = json.decode(body);
          return _parseFeedJson(data);
        }
        return [];
      }
      if (response.statusCode == 204) {
        return [];
      }
      throw Exception('Falha ao carregar o mural: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) debugPrint('Erro na requisicao do mural: $e');
      rethrow;
    }
  }

  List<AppContent> _parseFeedJson(List<dynamic> data) {
    return data
        .whereType<Map<String, dynamic>>()
        .map(AppContent.fromMap)
        .toList();
  }
}
