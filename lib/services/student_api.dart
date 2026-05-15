import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'request_context.dart';

class StudentApi {
  Future<String?> getStudentName(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/api/v2/students/$matricula');

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return jsonResponse['fullName']?.toString();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao buscar nome do aluno: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> getStudentData(
    String matricula,
    String token,
  ) async {
    final url = Uri.parse('$apiBaseUrl/api/v2/students/$matricula');

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse =
            json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return {
          ...jsonResponse,
          'nomeCompleto': jsonResponse['fullName'],
          'foto': jsonResponse['avatarUrl'],
          'penalidade': jsonResponse['penaltyCode']?['code'],
        };
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao buscar dados do aluno: $e');
    }
    return null;
  }
}
