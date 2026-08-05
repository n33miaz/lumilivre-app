import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import '../utils/parsers.dart';
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
        // `penaltyCode` e `penaltyExpiresAt` seguem crus no mapa: quem precisa da
        // penalidade lê com `ReaderPenalty.fromReaderJson`. Antes havia aqui uma
        // chave derivada `penalidade` com só o código, que jogava a data de
        // validade no lixo — e é a data que decide se a restrição ainda vale.
        return {
          ...jsonResponse,
          'nomeCompleto': jsonResponse['fullName'],
          // A foto do aluno é dado pessoal: passa pelo filtro de HTTPS antes de
          // chegar à tela. URL recusada vira null e o perfil usa o ícone local.
          'foto': secureMediaUrl(jsonResponse['avatarUrl']),
        };
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao buscar dados do leitor: $e');
    }
    return null;
  }
}
