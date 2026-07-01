import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/library_settings.dart';
import '../utils/constants.dart';
import 'request_context.dart';

class SettingsApi {
  SettingsApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<LibrarySettings> getSettings(String token) async {
    final url = Uri.parse('$apiBaseUrl/api/settings');

    try {
      final response = await _client
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data =
            json.decode(utf8.decode(response.bodyBytes))
                as Map<String, dynamic>;
        return LibrarySettings.fromJson(data);
      }

      throw Exception('Falha ao carregar settings: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) debugPrint('Erro getSettings: $e');
      rethrow;
    }
  }
}
