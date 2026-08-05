import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/user.dart';
import '../utils/constants.dart';
import 'api_error.dart';
import 'request_context.dart';

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Entra na conta. Erro sai como [ApiException] tipada, com a frase da API em
  /// [ApiException.apiMessage].
  ///
  /// O `catch` daqui engolia a recusa do servidor: qualquer status diferente de
  /// 200 virava `Exception(message)`, que o próprio `catch` capturava e trocava
  /// por "Não foi possível conectar ao servidor". Quem errava a senha era
  /// informado de que a internet tinha caído — e agora que a API distingue senha
  /// incorreta, conta desativada, conta bloqueada e excesso de tentativas, seriam
  /// quatro respostas diferentes reduzidas à mesma frase errada. A copy de
  /// conexão passa a valer só para falha de rede de verdade.
  Future<LoginResponse> login(String user, String password) async {
    final url = Uri.parse('$apiBaseUrl/api/auth/login');

    try {
      final response = await _client
          .post(
            url,
            headers: await RequestContext.jsonHeaders(),
            body: jsonEncode({'username': user, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loginResponseFromJson(utf8.decode(response.bodyBytes));
      }
      throw ApiException.fromResponse(response);
    } catch (e) {
      // Só o tipo do erro. Este é o caminho que carrega credencial: uma
      // FormatException de `jsonDecode` traz um trecho do corpo da resposta
      // junto na mensagem, e é isso que não pode acabar no log.
      final failure = ApiException.fromError(e);
      if (kDebugMode) debugPrint('Erro na chamada de login: $failure');
      throw failure;
    }
  }

  /// Troca a senha e devolve o token novo que a API emite na resposta.
  ///
  /// A troca revoga no servidor todo token emitido antes dela — inclusive o que
  /// autenticou esta requisição. Sem guardar o token da resposta, o próximo
  /// request do app leva credencial revogada e o usuário é deslogado no segundo
  /// seguinte a ter trocado a senha com sucesso.
  Future<String?> changePassword(
    String matricula,
    String currentPassword,
    String newPassword,
    String token,
  ) async {
    final url = Uri.parse('$apiBaseUrl/api/auth/change-password');

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

      // 204 é a resposta da API antiga: aceita para o app não quebrar contra um
      // servidor que ainda não subiu a versão nova.
      if (response.statusCode == 204) {
        return null;
      }
      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        return decoded is Map ? decoded['token']?.toString() : null;
      }
      throw ApiException.fromResponse(response);
    } catch (e) {
      // Idem login: a requisição leva senha atual e nova.
      final failure = ApiException.fromError(e);
      if (kDebugMode) debugPrint('Erro changePassword: $failure');
      throw failure;
    }
  }

  /// Encerra a sessão no servidor (revoga os tokens do usuário).
  ///
  /// Melhor esforço: o `false` não impede o app de limpar a sessão local, senão
  /// o usuário sem rede ficaria impedido de sair da conta no próprio aparelho.
  Future<bool> logout(String token) async {
    final url = Uri.parse('$apiBaseUrl/api/auth/logout');

    try {
      final response = await _client
          .post(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      final failure = ApiException.fromError(e);
      if (kDebugMode) debugPrint('Erro no logout: $failure');
      return false;
    }
  }

  /// Marca o tour guiado como concluído para o usuário atual.
  Future<bool> completeTour(String token) async {
    final url = Uri.parse('$apiBaseUrl/api/users/me/complete-tour');

    try {
      final response = await _client
          .post(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) debugPrint('Erro completeTour: $e');
      return false;
    }
  }
}
