import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/services/loan_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoanApi', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'requestLoan deve chamar endpoint por tombo com bearer token',
      () async {
        late http.Request capturedRequest;
        final api = LoanApi(
          client: MockClient((request) async {
            capturedRequest = request;
            return http.Response('', 200);
          }),
        );

        final success = await api.requestLoan('12345', 'T001', 'jwt-token');

        expect(success, isTrue);
        expect(capturedRequest.method, 'POST');
        expect(capturedRequest.url.path, endsWith('/api/loan-requests'));
        expect(capturedRequest.url.queryParameters, {
          'readerRegistrationNumber': '12345',
          'copyCode': 'T001',
        });
        expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
      },
    );

    test('requestLoanByBookId deve aceitar status 201', () async {
      final api = LoanApi(
        client: MockClient((request) async => http.Response('', 201)),
      );

      await expectLater(
        api.requestLoanByBookId('12345', '10', 'jwt-token'),
        completes,
      );
    });

    test(
      'requestLoanByBookId deve preservar a mensagem de recusa da API',
      () async {
        // 422 é o que `RequestApprovalPolicy` devolve, com a frase de
        // `request.policy.active-penalty` — a única coisa que explica ao leitor
        // por que o pedido não passou. Corpo copiado da resposta real da API.
        final body = jsonEncode({
          'status': 422,
          'error': 'Violação de Política de Negócio',
          'message': 'Leitor bloqueado por penalidade ativa até 2026-08-11.',
        });
        final api = LoanApi(
          client: MockClient(
            (request) async => http.Response.bytes(utf8.encode(body), 422),
          ),
        );

        await expectLater(
          api.requestLoanByBookId('12345', '10', 'jwt-token'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.failure, 'failure', ApiFailure.businessRule)
                .having(
                  (e) => e.apiMessage,
                  'apiMessage',
                  contains('penalidade ativa'),
                ),
          ),
        );
      },
    );

    test(
      'requestLoanByBookId deve marcar senha inicial pendente sem vazar o texto tecnico',
      () async {
        final api = LoanApi(
          client: MockClient(
            (request) async => http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'status': 403,
                  'error': 'Forbidden',
                  'message':
                      'Password change required before performing this action.',
                  'code': 'PASSWORD_CHANGE_REQUIRED',
                }),
              ),
              403,
            ),
          ),
        );

        await expectLater(
          api.requestLoanByBookId('12345', '10', 'jwt-token'),
          throwsA(
            isA<ApiException>()
                .having(
                  (e) => e.requiresPasswordChange,
                  'requiresPasswordChange',
                  isTrue,
                )
                .having((e) => e.needsAuthentication, 'nao desloga', isFalse)
                .having((e) => e.apiMessage, 'apiMessage', isNull),
          ),
        );
      },
    );

    test('getMyRequests deve parsear solicitacoes em loans', () async {
      final api = LoanApi(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode([
                {
                  'id': 7,
                  'readerName': 'Leitor Teste',
                  'readerRegistrationNumber': '12345',
                  'copyCode': 'T001',
                  'bookId': 10,
                  'bookTitle': 'Livro Teste',
                  'requestedAt': '2026-04-17T10:00:00',
                  'status': 'PENDING',
                  'notes': 'Solicitado via Mobile',
                },
              ]),
            ),
            200,
          );
        }),
      );

      final requests = await api.getMyRequests('12345', 'jwt-token');

      expect(requests, hasLength(1));
      expect(requests.single.livroTitulo, 'Livro Teste');
      expect(requests.single.status, 'PENDING');
    });

    test('getMyLoans deve retornar lista vazia quando API falha', () async {
      final api = LoanApi(
        client: MockClient((request) async => http.Response('', 500)),
      );

      final loans = await api.getMyLoans('12345', 'jwt-token');

      expect(loans, isEmpty);
    });

    /// Engolir a falha do histórico transformava "não deu para buscar" em "você
    /// nunca pegou um livro": a aba mostrava o estado vazio depois de uma queda
    /// de rede, sem saber que havia algo a tentar de novo.
    test('getMyLoansHistory deve jogar quando a API falha', () async {
      final api = LoanApi(
        client: MockClient((request) async => http.Response('', 500)),
      );

      await expectLater(
        api.getMyLoansHistory('12345', 'jwt-token'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.failure,
            'failure',
            ApiFailure.server,
          ),
        ),
      );
    });

    test('getMyLoansHistory deve tratar 204 como historico vazio', () async {
      final api = LoanApi(
        client: MockClient((request) async => http.Response('', 204)),
      );

      expect(await api.getMyLoansHistory('12345', 'jwt-token'), isEmpty);
    });
  });
}
