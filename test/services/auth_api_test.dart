import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumilivre/services/auth_api.dart';

void main() {
  group('AuthApi', () {
    test('login deve enviar credenciais e parsear resposta', () async {
      late http.Request capturedRequest;
      final api = AuthApi(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response(
            jsonEncode({
              'id': 1,
              'email': 'aluno@lumilivre.test',
              'role': 'ALUNO',
              'matriculaAluno': '12345',
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
      expect(capturedRequest.headers['Content-Type'], contains('application/json'));
      expect(jsonDecode(capturedRequest.body), {'user': '12345', 'senha': '12345'});
      expect(response.email, 'aluno@lumilivre.test');
      expect(response.role, 'ALUNO');
      expect(response.matriculaAluno, '12345');
      expect(response.token, 'jwt-token');
      expect(response.isInitialPassword, isTrue);
    });

    test('login deve expor mensagem generica quando API retorna erro', () async {
      final api = AuthApi(
        client: MockClient((request) async {
          return http.Response(jsonEncode({'message': 'Senha incorreta'}), 401);
        }),
      );

      expect(
        () => api.login('12345', 'errada'),
        throwsA(
          isA<Exception>().having(
            (error) => error.toString(),
            'message',
            contains('conectar'),
          ),
        ),
      );
    });

    test('changePassword deve enviar token e corpo esperado', () async {
      late http.Request capturedRequest;
      final api = AuthApi(
        client: MockClient((request) async {
          capturedRequest = request;
          return http.Response('', 200);
        }),
      );

      final changed = await api.changePassword('12345', 'atual', 'nova', 'jwt-token');

      expect(changed, isTrue);
      expect(capturedRequest.method, 'PUT');
      expect(capturedRequest.url.path, endsWith('/usuarios/alterar-senha'));
      expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
      expect(jsonDecode(capturedRequest.body), {
        'matricula': '12345',
        'senhaAtual': 'atual',
        'novaSenha': 'nova',
      });
    });
  });
}
