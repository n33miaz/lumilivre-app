import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'request_context.dart';

class ReaderApi {
  Future<String?> getReaderName(String registrationNumber, String token) async {
    final url = Uri.parse('$apiBaseUrl/api/readers/$registrationNumber');

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))
                as Map<String, dynamic>;
        return jsonResponse['fullName']?.toString();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao buscar nome do leitor: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getReaderData(
    String registrationNumber,
    String token,
  ) async {
    final url = Uri.parse('$apiBaseUrl/api/readers/$registrationNumber');

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes))
                as Map<String, dynamic>;
        return {
          ...jsonResponse,
          'nomeCompleto': jsonResponse['fullName'],
          'foto': jsonResponse['avatarUrl'],
          'penalidade': jsonResponse['penaltyCode']?['code'],
        };
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao buscar dados do leitor: $e');
    }
    return null;
  }
}
