import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class StudentApi {
  Future<String?> getStudentName(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/alunos/$matricula');

    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data']['nomeCompleto'];
        }
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
    final url = Uri.parse('$apiBaseUrl/alunos/$matricula');

    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data'];
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao buscar dados do aluno: $e');
    }
    return null;
  }
}
