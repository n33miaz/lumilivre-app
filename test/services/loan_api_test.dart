import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
          'studentRegistrationNumber': '12345',
          'copyCode': 'T001',
        });
        expect(capturedRequest.headers['Authorization'], 'Bearer jwt-token');
      },
    );

    test('requestLoanByBookId deve aceitar status 201', () async {
      final api = LoanApi(
        client: MockClient((request) async => http.Response('', 201)),
      );

      final success = await api.requestLoanByBookId('12345', '10', 'jwt-token');

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
                  'studentName': 'Aluno Teste',
                  'studentRegistrationNumber': '12345',
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
  });
}
