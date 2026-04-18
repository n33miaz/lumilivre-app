import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/ranking.dart';
import '../utils/constants.dart';

class RankingApi {
  Future<List<RankingItem>> getRanking({
    int top = 50,
    int? cursoId,
    int? moduloId,
    int? turnoId,
    required String token,
  }) async {
    String query = '?top=$top';
    if (cursoId != null) query += '&cursoId=$cursoId';
    if (moduloId != null) query += '&moduloId=$moduloId';
    if (turnoId != null) query += '&turnoId=$turnoId';

    final url = Uri.parse('$apiBaseUrl/emprestimos/ranking$query');

    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => RankingItem.fromJson(e)).toList();
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception('Erro ao buscar ranking');
      }
    } catch (e) {
      debugPrint('Erro getRanking: $e');
      return [];
    }
  }

  Future<List<FilterItem>> getSimpleList(String endpoint, String token) async {
    final url = Uri.parse('$apiBaseUrl/$endpoint');

    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => FilterItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao buscar $endpoint: $e');
      return [];
    }
  }

  Future<List<FilterItem>> getCursos(String token) async {
    final url = Uri.parse('$apiBaseUrl/cursos/home?size=100');

    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> content = data['content'];
        return content.map((e) => FilterItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao buscar cursos: $e');
      return [];
    }
  }
}
