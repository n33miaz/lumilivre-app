import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/services/api_health.dart';

/// Tempo suficiente para o `MockClient` responder: ele resolve em microtask, não
/// em timer, então não há relógio falso para adiantar.
Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final health = ApiHealth.instance;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    health.resetForTest();
  });

  tearDown(health.resetForTest);

  group('monitor desligado', () {
    test('nao instala gancho nem muda de estado', () {
      ApiException.fromError(const SocketException('sem rota'));

      // É o que mantém os testes de unidade — e qualquer uso de `fromError`
      // fora do app rodando — livres de requisição e de timer.
      expect(health.status, ApiHealthStatus.unknown);
    });

    test('waitUntilReachable nao pendura ninguem', () async {
      expect(await health.waitUntilReachable(), isFalse);
    });
  });

  group('quem responde e quem cala', () {
    test('falha de transporte poe o servidor como acordando', () {
      health.enable(client: MockClient((_) async => http.Response('', 200)));

      ApiException.fromError(const SocketException('sem resposta'));

      expect(health.status, ApiHealthStatus.waking);
      expect(health.isWaking, isTrue);
    });

    test('recusa do servidor nao e servidor calado', () {
      health.enable(client: MockClient((_) async => http.Response('', 200)));

      // 401, 404, 422, 5xx: em todos alguém atendeu. Tratar isto como servidor
      // dormindo faria a faixa aparecer com a API perfeitamente no ar.
      ApiException.fromError(const ApiException(ApiFailure.unauthorized));

      expect(health.status, ApiHealthStatus.reachable);
    });

    test('qualquer status do ping conta como servidor de pe', () async {
      // 503 é o que uma instância subindo responde: é resposta, e resposta
      // significa que o processo atende.
      health.enable(client: MockClient((_) async => http.Response('', 503)));

      health.warmUp();
      await settle();

      expect(health.status, ApiHealthStatus.reachable);
    });
  });

  group('aquecimento', () {
    test('gatilhos sobrepostos valem um ping so', () async {
      var calls = 0;
      health.enable(
        client: MockClient((_) async {
          calls++;
          return http.Response('', 200);
        }),
      );

      // Abrir o app e cair na tela de login acontecem no mesmo segundo.
      health.warmUp();
      health.warmUp();
      await settle();

      expect(calls, 1);

      // E o terceiro gatilho (voltar do segundo plano logo depois) também não
      // acrescenta nada: o servidor acabou de provar que está de pé.
      health.warmUp();
      await settle();

      expect(calls, 1);
    });

    test('ping que nao volta poe a faixa de "acordando" no ar', () async {
      health.enable(
        client: MockClient(
          (_) async => throw const SocketException('instância dormindo'),
        ),
      );

      health.warmUp();
      await settle();

      expect(health.status, ApiHealthStatus.waking);
      expect(health.silentFor, lessThan(const Duration(seconds: 5)));
    });
  });

  group('volta ao normal', () {
    test('quem esperava o servidor e liberado quando ele atende', () async {
      health.enable(client: MockClient((_) async => http.Response('', 200)));
      ApiException.fromError(const SocketException('sem resposta'));
      expect(health.isWaking, isTrue);

      // É este `Future` que segura a chamada que falhou, em vez de devolver
      // erro para a tela e obrigar a pessoa a sair e entrar no app.
      final waiting = health.waitUntilReachable();
      health.retryNow();

      expect(await waiting, isTrue);
      expect(health.status, ApiHealthStatus.reachable);
      expect(health.silentFor, Duration.zero);
    });

    test(
      'tentar de novo com o servidor ainda calado mantem a espera',
      () async {
        health.enable(
          client: MockClient((_) async => throw const SocketException('nada')),
        );
        ApiException.fromError(const SocketException('nada'));

        health.retryNow();
        await settle();

        expect(health.status, ApiHealthStatus.waking);
      },
    );
  });
}
