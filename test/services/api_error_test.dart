import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lumilivre/services/api_error.dart';

void main() {
  group('ApiException.fromStatus', () {
    test('401 e 403 devem virar falta de autenticacao', () {
      expect(ApiException.fromStatus(401).failure, ApiFailure.unauthorized);
      expect(ApiException.fromStatus(403).failure, ApiFailure.unauthorized);
      expect(ApiException.fromStatus(401).needsAuthentication, isTrue);
    });

    test('404 deve virar recurso inexistente', () {
      expect(ApiException.fromStatus(404).failure, ApiFailure.notFound);
    });

    test('5xx deve virar falha de servidor e permitir nova tentativa', () {
      final failure = ApiException.fromStatus(503);
      expect(failure.failure, ApiFailure.server);
      expect(failure.isRetryable, isTrue);
    });

    test('deve preservar o status para diagnostico', () {
      expect(ApiException.fromStatus(418).statusCode, 418);
    });
  });

  group('ApiException.fromError', () {
    test('timeout e socket devem virar falha de rede', () {
      expect(
        ApiException.fromError(TimeoutException('t')).failure,
        ApiFailure.network,
      );
      expect(
        ApiException.fromError(const SocketException('sem rota')).failure,
        ApiFailure.network,
      );
      expect(
        ApiException.fromError(http.ClientException('falhou')).failure,
        ApiFailure.network,
      );
    });

    test('falha de rede deve permitir nova tentativa', () {
      expect(ApiException.fromError(TimeoutException('t')).isRetryable, isTrue);
    });

    test('json fora do contrato deve virar resposta invalida', () {
      expect(
        ApiException.fromError(const FormatException('json')).failure,
        ApiFailure.invalidResponse,
      );
    });

    test('deve preservar a classificacao ja feita', () {
      const original = ApiException(ApiFailure.unauthorized, statusCode: 401);
      final reclassified = ApiException.fromError(original);
      expect(reclassified.failure, ApiFailure.unauthorized);
      expect(reclassified.statusCode, 401);
    });

    test('falta de autenticacao nao deve pedir nova tentativa', () {
      expect(ApiException.fromStatus(401).isRetryable, isFalse);
    });
  });

  group('ApiException.fromResponse', () {
    http.Response jsonResponse(int status, Map<String, dynamic> body) =>
        http.Response.bytes(utf8.encode(jsonEncode(body)), status);

    test('deve preservar a mensagem que a API ja traduziu', () {
      final failure = ApiException.fromResponse(
        jsonResponse(401, {'message': 'Credenciais inválidas.'}),
      );
      expect(failure.failure, ApiFailure.unauthorized);
      expect(failure.apiMessage, 'Credenciais inválidas.');
    });

    test('422 deve virar recusa de regra de negocio', () {
      final failure = ApiException.fromResponse(
        jsonResponse(422, {
          'message': 'Limite de empréstimos ativos atingido.',
        }),
      );
      expect(failure.failure, ApiFailure.businessRule);
      expect(failure.isRetryable, isFalse);
      expect(failure.needsAuthentication, isFalse);
    });

    /// A senha inicial pendente é 403 como qualquer negativa, mas tratá-la como
    /// falta de sessão levaria a deslogar — e a saída é justamente o formulário de
    /// troca de senha, que só existe dentro da sessão.
    test('403 de senha inicial nao deve virar falta de autenticacao', () {
      final failure = ApiException.fromResponse(
        jsonResponse(403, {
          'message': 'Password change required before performing this action.',
          'code': 'PASSWORD_CHANGE_REQUIRED',
        }),
      );
      expect(failure.failure, ApiFailure.passwordChangeRequired);
      expect(failure.requiresPasswordChange, isTrue);
      expect(failure.needsAuthentication, isFalse);
    });

    test('403 de senha inicial nao deve expor o texto tecnico em ingles', () {
      final failure = ApiException.fromResponse(
        jsonResponse(403, {
          'message': 'Password change required before performing this action.',
          'code': 'PASSWORD_CHANGE_REQUIRED',
        }),
      );
      expect(failure.apiMessage, isNull);
    });

    test('403 comum deve continuar sendo falta de autorizacao', () {
      final failure = ApiException.fromResponse(
        jsonResponse(403, {'message': 'Acesso negado.'}),
      );
      expect(failure.failure, ApiFailure.unauthorized);
      expect(failure.requiresPasswordChange, isFalse);
    });

    test('corpo vazio ou fora de JSON nao deve quebrar a classificacao', () {
      expect(
        ApiException.fromResponse(http.Response('', 500)).failure,
        ApiFailure.server,
      );
      final html = ApiException.fromResponse(
        http.Response('<html>502 Bad Gateway</html>', 502),
      );
      expect(html.failure, ApiFailure.server);
      expect(html.apiMessage, isNull);
    });

    test('mensagem em branco deve ser tratada como ausente', () {
      final failure = ApiException.fromResponse(
        jsonResponse(500, {'message': '   '}),
      );
      expect(failure.apiMessage, isNull);
    });
  });

  group('mensagem do erro', () {
    test('nao deve carregar corpo de resposta nem credencial', () {
      expect(
        ApiException.fromStatus(401).toString(),
        'ApiException(unauthorized, 401)',
      );
      expect(
        const ApiException(ApiFailure.network).toString(),
        'ApiException(network)',
      );
    });

    /// A frase da API é para a tela mostrar, não para o log guardar: ela pode
    /// citar matrícula, nome ou data de penalidade de um aluno.
    test('nao deve levar a mensagem da API para o toString', () {
      const failure = ApiException(
        ApiFailure.businessRule,
        statusCode: 422,
        apiMessage: 'Leitor 2024008 bloqueado por penalidade ativa.',
      );
      expect(failure.toString(), 'ApiException(businessRule, 422)');
    });
  });
}
