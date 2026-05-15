import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../utils/constants.dart';
import 'request_context.dart';

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<LoginResponse> login(String user, String password) async {
    final url = Uri.parse('$apiBaseUrl/api/v2/auth/login');

    try {
      final response = await _client
          .post(
            url,
            headers: await RequestContext.jsonHeaders(),
            body: jsonEncode({'username': user, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loginResponseFromJson(response.body);
      }

      final errorData = jsonDecode(response.body);
      throw Exception(
        errorData['message']?.toString() ?? 'Falha no login',
      );
    } catch (e) {
      debugPrint('Erro na chamada de login: $e');
      throw Exception(
        'Nao foi possivel conectar ao servidor. Tente novamente.',
      );
    }
  }

  Future<bool> changePassword(
    String matricula,
    String currentPassword,
    String newPassword,
    String token,
  ) async {
    final url = Uri.parse('$apiBaseUrl/api/v2/auth/change-password');

    try {
      final response = await _client
          .put(
            url,
            headers: await RequestContext.jsonHeaders(token: token),
            body: jsonEncode({
              'registrationNumber': matricula,
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 204) {
        return true;
      }

      final errorData = jsonDecode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['message'] ?? 'Erro ao alterar senha');
    } catch (e) {
      debugPrint('Erro changePassword: $e');
      rethrow;
    }
  }
}
