import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import '../models/user.dart';

class ApiService {
  Future<LoginResponse> login(String user, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'user': user, 'senha': password}),
      );

      if (response.statusCode == 200) {
        return loginResponseFromJson(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Falha no login');
      }
    } catch (e) {
      print('Erro na chamada de login: $e');
      throw Exception(
        'Não foi possível conectar ao servidor. Tente novamente.',
      );
    }
  }

  Future<String> requestPasswordReset(String email) async {
    final url = Uri.parse('$apiBaseUrl/auth/esqueci-senha');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['mensagem'] ?? 'Solicitação enviada.';
      } else {
        throw Exception('Falha ao solicitar reset.');
      }
    } catch (e) {
      print('Erro em requestPasswordReset: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  Future<bool> validateResetToken(String token) async {
    final url = Uri.parse('$apiBaseUrl/auth/validar-token/$token');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valido'] ?? false;
      }
      return false;
    } catch (e) {
      print('Erro em validateResetToken: $e');
      return false;
    }
  }

  Future<String> changePasswordWithToken(
    String token,
    String newPassword,
  ) async {
    final url = Uri.parse('$apiBaseUrl/auth/mudar-senha');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'token': token, 'novaSenha': newPassword}),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['mensagem'] ?? 'Senha alterada com sucesso.';
      } else {
        throw Exception(
          data['mensagem'] ?? 'Não foi possível alterar a senha.',
        );
      }
    } catch (e) {
      print('Erro em changePasswordWithToken: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }
}