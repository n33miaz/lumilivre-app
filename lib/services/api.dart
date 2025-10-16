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
}
