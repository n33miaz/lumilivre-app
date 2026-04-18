import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../utils/constants.dart';

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<LoginResponse> login(String user, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/login');

    try {
      final response = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'user': user, 'senha': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loginResponseFromJson(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          errorData['mensagem'] ?? errorData['message'] ?? 'Falha no login',
        );
      }
    } catch (e) {
      debugPrint('Erro na chamada de login: $e');
      throw Exception(
        'Não foi possível conectar ao servidor. Tente novamente.',
      );
    }
  }

  Future<bool> changePassword(
    String matricula,
    String currentPassword,
    String newPassword,
    String token,
  ) async {
    final url = Uri.parse('$apiBaseUrl/usuarios/alterar-senha');

    try {
      final response = await _client
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'matricula': matricula,
              'senhaAtual': currentPassword,
              'novaSenha': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? 'Erro ao alterar senha');
      }
    } catch (e) {
      debugPrint('Erro changePassword: $e');
      rethrow;
    }
  }
}
