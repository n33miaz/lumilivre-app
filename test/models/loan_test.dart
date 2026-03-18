import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/loan.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Loan', () {
    group('fromJson (empréstimo)', () {
      test('deve criar Loan ativo com dados completos', () {
        final loan = Loan.fromJson(LoanFixtures.activeLoan);
        expect(loan.id, 1);
        expect(loan.dataEmprestimo, DateTime(2025, 3, 1));
        expect(loan.dataDevolucao, DateTime(2025, 3, 15));
        expect(loan.status, 'ATIVO');
        expect(loan.penalidade, isNull);
        expect(loan.livroId, 10);
        expect(loan.livroTitulo, 'Duna');
        expect(loan.imagemUrl, 'https://example.com/duna.jpg');
        expect(loan.isRequest, isFalse);
      });

      test('deve criar Loan atrasado com penalidade', () {
        final loan = Loan.fromJson(LoanFixtures.overdueLoan);
        expect(loan.id, 2);
        expect(loan.status, 'ATRASADO');
        expect(loan.penalidade, contains('Multa'));
        expect(loan.imagemUrl, isNull);
      });

      test('deve usar fallbacks para campos nulos', () {
        final loan = Loan.fromJson({
          'id': null,
          'dataEmprestimo': null,
          'dataDevolucao': null,
          'status': null,
          'livroId': null,
          'livroTitulo': null,
        });
        expect(loan.id, 0);
        expect(loan.status, 'DESCONHECIDO');
        expect(loan.livroId, 0);
        expect(loan.livroTitulo, 'Livro sem título');
        expect(loan.isRequest, isFalse);
      });

      test('deve converter id do tipo String', () {
        final loan = Loan.fromJson({
          ...LoanFixtures.activeLoan,
          'id': '99',
          'livroId': '42',
        });
        expect(loan.id, 99);
        expect(loan.livroId, 42);
      });

      test('deve converter id do tipo double', () {
        final loan = Loan.fromJson({...LoanFixtures.activeLoan, 'id': 7.9});
        expect(loan.id, 7);
      });
    });

    group('fromRequestJson (solicitação)', () {
      test('deve criar Loan de solicitação pendente', () {
        final loan = Loan.fromRequestJson(LoanFixtures.pendingRequest);
        expect(loan.id, 3);
        expect(loan.status, 'PENDENTE');
        expect(loan.livroId, 30);
        expect(loan.livroTitulo, 'Livro Solicitado');
        expect(loan.isRequest, isTrue);
        expect(loan.imagemUrl, isNull);
        expect(loan.dataDevolucao, DateTime(2100));
      });

      test('deve criar Loan de solicitação rejeitada', () {
        final loan = Loan.fromRequestJson(LoanFixtures.rejectedRequest);
        expect(loan.id, 4);
        expect(loan.status, 'REJEITADA');
        expect(loan.livroTitulo, 'Livro Rejeitado');
        expect(loan.isRequest, isTrue);
      });

      test('deve usar fallbacks para campos nulos em solicitação', () {
        final loan = Loan.fromRequestJson({
          'id': null,
          'dataSolicitacao': null,
          'status': null,
          'livroId': null,
          'livroNome': null,
        });
        expect(loan.id, 0);
        expect(loan.status, 'PENDENTE');
        expect(loan.livroId, 0);
        expect(loan.livroTitulo, 'Solicitação');
        expect(loan.isRequest, isTrue);
      });

      test('deve usar DateTime.now() para data inválida em solicitação', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final loan = Loan.fromRequestJson({
          ...LoanFixtures.pendingRequest,
          'dataSolicitacao': 'data-lixo',
        });
        final after = DateTime.now().add(const Duration(seconds: 1));
        expect(loan.dataEmprestimo.isAfter(before), isTrue);
        expect(loan.dataEmprestimo.isBefore(after), isTrue);
      });
    });

    group('parseDate no fromJson', () {
      test('deve parsear data como List [year, month, day]', () {
        final loan = Loan.fromJson(LoanFixtures.activeLoan);
        expect(loan.dataEmprestimo, DateTime(2025, 3, 1));
      });

      test('deve parsear data como String ISO', () {
        final loan = Loan.fromJson({
          ...LoanFixtures.activeLoan,
          'dataEmprestimo': '2025-06-15',
        });
        expect(loan.dataEmprestimo, DateTime(2025, 6, 15));
      });

      test('deve usar DateTime.now() para data inválida', () {
        final before = DateTime.now().subtract(const Duration(seconds: 1));
        final loan = Loan.fromJson({
          ...LoanFixtures.activeLoan,
          'dataEmprestimo': 'invalid',
        });
        final after = DateTime.now().add(const Duration(seconds: 1));
        expect(loan.dataEmprestimo.isAfter(before), isTrue);
        expect(loan.dataEmprestimo.isBefore(after), isTrue);
      });

      test('deve parsear List com apenas [year]', () {
        final loan = Loan.fromJson({
          ...LoanFixtures.activeLoan,
          'dataEmprestimo': [2024],
        });
        expect(loan.dataEmprestimo, DateTime(2024, 1, 1));
      });
    });

    group('loanFromJson', () {
      test('deve parsear lista JSON de empréstimos', () {
        final jsonStr = json.encode([
          LoanFixtures.activeLoan,
          LoanFixtures.overdueLoan,
        ]);
        final loans = loanFromJson(jsonStr);
        expect(loans, hasLength(2));
        expect(loans[0].livroTitulo, 'Duna');
        expect(loans[1].livroTitulo, 'Livro Atrasado');
      });

      test('deve retornar lista vazia para JSON null', () {
        expect(loanFromJson('null'), isEmpty);
      });

      test('deve retornar lista vazia para JSON não-lista', () {
        expect(loanFromJson('{"key":"value"}'), isEmpty);
      });

      test('deve retornar lista vazia para lista vazia', () {
        expect(loanFromJson('[]'), isEmpty);
      });
    });
  });
}
