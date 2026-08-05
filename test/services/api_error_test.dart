import 'dart:async';
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
  });
}
