import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/services/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthApi', () {
    test('login deve enviar credenciais e parsear resposta', () async {
      late http.Request capturedRequest;
      final api = AuthApi(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'id': 1,
              'email': 'leitor@lumilivre.test',
              'role': 'READER',
              'readerRegistrationNumber': '12345',
              'token': 'jwt-token',
              'isInitialPassword': true,
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final response = await api.login('12345', '12345');

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, endsWith('/auth/login'));
      expect(
        capturedRequest.headers['Content-Type'],
        contains('application/json'),
      );
      expect(jsonDecode(capturedRequest.body), {
        'username': '12345',
        'password': '12345',
      });
      expect(response.email, 'leitor@lumilivre.test');
      expect(response.role, 'READER');
      expect(response.readerRegistrationNumber, '12345');
      expect(response.token, 'jwt-token');
      expect(response.isInitialPassword, isTrue);
    });

    /// Este era o defeito: a recusa do servidor era capturada pelo próprio
    /// `catch` do método e substituída pela copy de falha de conexão. Quem errava
    /// a senha era informado de que a internet tinha caído.
    test('login deve preservar a mensagem de senha incorreta', () async {
      final api = AuthApi(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({'status': 401, 'message': 'Credenciais inválidas.'}),
            ),
            401,
          );
        }),
      );

      await expectLater(
        api.login('12345', 'errada'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.failure, 'failure', ApiFailure.unauthorized)
              .having(
                (e) => e.apiMessage,
                'apiMessage',
                'Credenciais inválidas.',
              ),
        ),
      );
    });

    test('login deve preservar a mensagem de conta desativada (403)', () async {
      final api = AuthApi(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'status': 403,
                'message':
                    'Conta desativada. Entre em contato com o administrador.',
              }),
            ),
            403,
          );
        }),
      );

      await expectLater(
        api.login('12345', 'certa'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.apiMessage,
            'apiMessage',
            contains('desativada'),
          ),
        ),
      );
    });

    test('login deve classificar timeout como falha de rede', () async {
      final api = AuthApi(
        client: MockClient((request) async {
          throw const SocketException('sem rota');
        }),
      );

      await expectLater(
        api.login('12345', 'certa'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.failure, 'failure', ApiFailure.network)
              .having((e) => e.apiMessage, 'sem mensagem da API', isNull),
        ),
      );
    });

    test('changePassword deve enviar token e corpo esperado', () async {
      late http.Request capturedRequest;
      final api = AuthApi(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 204);
        }),
      );

      final newToken = await api.changePassword(
        '12345',
        'atual',
        'nova',
        'jwt-token',
      );

      // 204 é a resposta do servidor antigo: sem token novo para adotar.
      expect(newToken, isNull);
      expect(capturedRequest.method, 'PUT');
      expect(capturedRequest.url.path, endsWith('/api/auth/change-password'));
      expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
      expect(jsonDecode(capturedRequest.body), {
        'registrationNumber': '12345',
        'currentPassword': 'atual',
        'newPassword': 'nova',
      });
    });

    /// A troca revoga no servidor os tokens emitidos antes dela, o desta
    /// requisição incluído: sem devolver o token da resposta, o app deslogaria o
    /// usuário no request seguinte ao sucesso.
    test('changePassword deve devolver o token novo da resposta 200', () async {
      final api = AuthApi(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(jsonEncode({'token': 'jwt-novo'})),
            200,
          );
        }),
      );

      final newToken = await api.changePassword(
        '12345',
        'atual',
        'nova',
        'jwt-antigo',
      );

      expect(newToken, 'jwt-novo');
    });

    test('changePassword deve preservar a mensagem de senha fraca', () async {
      final api = AuthApi(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'status': 400,
                'message': 'A senha precisa ter ao menos 8 caracteres.',
              }),
            ),
            400,
          );
        }),
      );

      await expectLater(
        api.changePassword('12345', 'atual', '123', 'jwt-token'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.apiMessage,
            'apiMessage',
            contains('8 caracteres'),
          ),
        ),
      );
    });

    test('logout deve revogar a sessao no servidor', () async {
      late http.Request capturedRequest;
      final api = AuthApi(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 204);
        }),
      );

      expect(await api.logout('jwt-token'), isTrue);
      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.path, endsWith('/api/auth/logout'));
      expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
    });

    test('logout nao deve impedir a saida quando a rede falha', () async {
      final api = AuthApi(
        client: MockClient((request) async {
          throw const SocketException('sem rota');
        }),
      );

      expect(await api.logout('jwt-token'), isFalse);
    });
  });
}
