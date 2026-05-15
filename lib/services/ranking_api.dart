import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/ranking.dart';
import '../utils/constants.dart';
import 'request_context.dart';

class RankingApi {
  Future<List<RankingItem>> getRanking({
    int top = 50,
    int? cursoId,
    int? moduloId,
    int? turnoId,
    required String token,
  }) async {
    var query = '?top=$top';
    if (cursoId != null) query += '&courseId=$cursoId';
    if (moduloId != null) query += '&academicModuleId=$moduloId';
    if (turnoId != null) query += '&studyShiftId=$turnoId';

    final url = Uri.parse('$apiBaseUrl/api/v2/students/ranking$query');

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes)) as List<dynamic>;
        return data
            .map((e) => RankingItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (response.statusCode == 204) {
        return [];
      }
      throw Exception('Erro ao buscar ranking');
    } catch (e) {
      debugPrint('Erro getRanking: $e');
      return [];
    }
  }

  Future<List<FilterItem>> getSimpleList(String endpoint, String token) async {
    final endpointMap = {
      'modulos': 'academic-modules',
      'turnos': 'study-shifts',
      'generos': 'genres',
    };
    final target = endpointMap[endpoint] ?? endpoint;
    final url = Uri.parse('$apiBaseUrl/api/v2/$target?size=100');

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final page = json.decode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        final data = (page['content'] ?? []) as List<dynamic>;
        return data
            .map((e) => FilterItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao buscar $endpoint: $e');
      return [];
    }
  }

  Future<List<FilterItem>> getCursos(String token) async {
    final url = Uri.parse('$apiBaseUrl/api/v2/courses?size=100');

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        final content = (data['content'] ?? []) as List<dynamic>;
        return content
            .map((e) => FilterItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Erro ao buscar cursos: $e');
      return [];
    }
  }
}
