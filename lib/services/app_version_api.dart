import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/app_version_info.dart';
import '../utils/constants.dart';
import 'request_context.dart';

class AppVersionApi {
  AppVersionApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Consulta a versão publicada para a [platform] informada (ANDROID/IOS).
  ///
  /// Endpoint público: não envia token. Usa um timeout curto para não atrasar
  /// a inicialização do app; o provider trata falhas com fail-open.
  Future<AppVersionInfo> get({required String platform}) async {
    final url = Uri.parse('$apiBaseUrl/api/app-version?platform=$platform');

    final response = await _client
        .get(url, headers: await RequestContext.headers())
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final data =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return AppVersionInfo.fromJson(data);
    }

    if (kDebugMode) {
      debugPrint('Erro getAppVersion: status ${response.statusCode}');
    }
    throw Exception('Falha ao consultar versão do app: ${response.statusCode}');
  }
}
