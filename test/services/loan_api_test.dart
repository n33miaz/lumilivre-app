import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumilivre/services/loan_api.dart';

void main() {
  group('LoanApi', () {
    test('requestLoan deve chamar endpoint por tombo com bearer token', () async {
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
      expect(capturedRequest.url.path, endsWith('/solicitacoes/solicitar'));
      expect(capturedRequest.url.queryParameters, {
        'matriculaAluno': '12345',
        'tomboExemplar': 'T001',
      });
      expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
    });

    test('requestLoanByBookId deve aceitar status 201', () async {
      final api = LoanApi(
        client: MockClient((request) async => http.Response('', 201)),
      );

      final success = await api.requestLoanByBookId('12345', 10, 'jwt-token');

      expect(success, isTrue);
    });

    test('getMyRequests deve parsear solicitacoes em loans', () async {
      final api = LoanApi(
        client: MockClient((request) async {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode([
                {
                  'id': 7,
                  'alunoNome': 'Aluno Teste',
                  'alunoMatricula': '12345',
                  'tomboExemplar': 'T001',
                  'livroId': 10,
                  'livroNome': 'Livro Teste',
                  'dataSolicitacao': '2026-04-17T10:00:00',
                  'status': 'PENDENTE',
                  'observacao': 'Solicitado via Mobile',
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
      expect(requests.single.status, 'PENDENTE');
    });

    test('getMyLoans deve retornar lista vazia quando API falha', () async {
      final api = LoanApi(
        client: MockClient((request) async => http.Response('', 500)),
      );

      final loans = await api.getMyLoans('12345', 'jwt-token');

      expect(loans, isEmpty);
    });
  });
}
