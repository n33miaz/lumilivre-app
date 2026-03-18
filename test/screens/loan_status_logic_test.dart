import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/book_details.dart';
import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/screens/book_details.dart';
import 'package:lumilivre/services/loan_status_calculator.dart';
import '../helpers/test_helpers.dart';

/// Testes do [LoanStatusCalculator] — regra de negócio mais crítica do app.
void main() {
  group('LoanStatusCalculator', () {
    late BookDetails availableBook;
    late BookDetails unavailableBook;
    late BookDetails noCopiesBook;

    setUp(() {
      availableBook = BookDetails.fromJson({
        ...BookDetailsFixtures.validApiResponse,
        'exemplaresDisponiveis': 3,
        'totalExemplares': 5,
      });
      unavailableBook = BookDetails.fromJson({
        ...BookDetailsFixtures.validApiResponse,
        'exemplaresDisponiveis': 0,
        'totalExemplares': 5,
      });
      noCopiesBook = BookDetails.fromJson({
        ...BookDetailsFixtures.validApiResponse,
        'exemplaresDisponiveis': 0,
        'totalExemplares': 0,
      });
    });

    LoanStatusResult calc({
      required BookDetails details,
      List<Loan>? loans,
      List<dynamic>? requests,
      Map<String, dynamic>? studentData,
      int targetBookId = 1,
    }) {
      return LoanStatusCalculator.calculate(
        details: details,
        loans: loans ?? [],
        requests: requests ?? [],
        targetBookId: targetBookId,
        studentData: studentData ?? {'penalidade': null},
      );
    }

    test('deve retornar AVAILABLE quando livro tem exemplares e aluno pode emprestar', () {
      final result = calc(details: availableBook);
      expect(result.status, LoanStatus.available);
      expect(result.dueDate, isNull);
    });

    test('deve retornar ACTIVE quando aluno tem empréstimo ativo do livro', () {
      final loan = Loan(
        id: 1,
        dataEmprestimo: DateTime.now().subtract(const Duration(days: 5)),
        dataDevolucao: DateTime.now().add(const Duration(days: 10)),
        status: 'ATIVO', livroId: 1, livroTitulo: 'Duna',
      );
      final result = calc(details: availableBook, loans: [loan]);
      expect(result.status, LoanStatus.active);
      expect(result.dueDate, isNotNull);
    });

    test('deve retornar OVERDUE quando devolução já passou', () {
      final loan = Loan(
        id: 1,
        dataEmprestimo: DateTime.now().subtract(const Duration(days: 30)),
        dataDevolucao: DateTime.now().subtract(const Duration(days: 1)),
        status: 'ATIVO', livroId: 1, livroTitulo: 'Duna',
      );
      final result = calc(details: availableBook, loans: [loan]);
      expect(result.status, LoanStatus.overdue);
    });

    test('deve retornar PENDING quando há solicitação pendente', () {
      final result = calc(
        details: availableBook,
        requests: [{'livroId': 1, 'status': 'PENDENTE'}],
      );
      expect(result.status, LoanStatus.pending);
    });

    test('não deve considerar solicitação de outro livro', () {
      final result = calc(
        details: availableBook,
        requests: [{'livroId': 99, 'status': 'PENDENTE'}],
      );
      expect(result.status, LoanStatus.available);
    });

    test('não deve considerar solicitação não-pendente', () {
      final result = calc(
        details: availableBook,
        requests: [{'livroId': 1, 'status': 'REJEITADA'}],
      );
      expect(result.status, LoanStatus.available);
    });

    test('deve retornar NO_COPIES quando totalExemplares é 0', () {
      final result = calc(details: noCopiesBook);
      expect(result.status, LoanStatus.noCopies);
    });

    test('deve retornar BLOCKED_PENALTY quando aluno tem penalidade', () {
      final result = calc(
        details: availableBook,
        studentData: {'penalidade': 'Multa R\$5,00'},
      );
      expect(result.status, LoanStatus.blockedPenalty);
    });

    test('não deve considerar penalidade "null" (string)', () {
      final result = calc(
        details: availableBook,
        studentData: {'penalidade': 'null'},
      );
      expect(result.status, LoanStatus.available);
    });

    test('deve retornar LIMIT_REACHED quando aluno tem 3+ empréstimos', () {
      final loans = List.generate(3, (i) => Loan(
        id: i, dataEmprestimo: DateTime.now(),
        dataDevolucao: DateTime.now().add(const Duration(days: 14)),
        status: 'ATIVO', livroId: 100 + i, livroTitulo: 'Livro $i',
      ));
      final result = calc(details: availableBook, loans: loans);
      expect(result.status, LoanStatus.limitReached);
    });

    test('não deve bloquear com 2 empréstimos', () {
      final loans = List.generate(2, (i) => Loan(
        id: i, dataEmprestimo: DateTime.now(),
        dataDevolucao: DateTime.now().add(const Duration(days: 14)),
        status: 'ATIVO', livroId: 100 + i, livroTitulo: 'Livro $i',
      ));
      final result = calc(details: availableBook, loans: loans);
      expect(result.status, LoanStatus.available);
    });

    test('deve retornar UNAVAILABLE quando não há exemplares disponíveis', () {
      final result = calc(details: unavailableBook);
      expect(result.status, LoanStatus.unavailable);
    });

    group('prioridade das regras', () {
      test('empréstimo ativo deve ter prioridade sobre penalidade', () {
        final loan = Loan(
          id: 1, dataEmprestimo: DateTime.now(),
          dataDevolucao: DateTime.now().add(const Duration(days: 10)),
          status: 'ATIVO', livroId: 1, livroTitulo: 'Duna',
        );
        final result = calc(
          details: availableBook, loans: [loan],
          studentData: {'penalidade': 'Multa'},
        );
        expect(result.status, LoanStatus.active);
      });

      test('solicitação pendente deve ter prioridade sobre noCopies', () {
        final result = calc(
          details: noCopiesBook,
          requests: [{'livroId': 1, 'status': 'PENDENTE'}],
        );
        expect(result.status, LoanStatus.pending);
      });

      test('noCopies deve ter prioridade sobre penalidade', () {
        final result = calc(
          details: noCopiesBook,
          studentData: {'penalidade': 'Multa'},
        );
        expect(result.status, LoanStatus.noCopies);
      });

      test('penalidade deve ter prioridade sobre limitReached', () {
        final loans = List.generate(3, (i) => Loan(
          id: i, dataEmprestimo: DateTime.now(),
          dataDevolucao: DateTime.now().add(const Duration(days: 14)),
          status: 'ATIVO', livroId: 100 + i, livroTitulo: 'Livro $i',
        ));
        final result = calc(
          details: availableBook, loans: loans,
          studentData: {'penalidade': 'Multa'},
        );
        expect(result.status, LoanStatus.blockedPenalty);
      });
    });

    group('edge cases', () {
      test('studentData null não deve crashar', () {
        final result = LoanStatusCalculator.calculate(
          details: availableBook, loans: [], requests: [],
          targetBookId: 1, studentData: null,
        );
        expect(result.status, LoanStatus.available);
      });

      test('requests com dados inválidos não devem crashar', () {
        final result = calc(
          details: availableBook,
          requests: [{'livroId': null, 'status': null}],
        );
        expect(result.status, LoanStatus.available);
      });

      test('dueDate deve ser preenchido em empréstimo ativo', () {
        final dueDate = DateTime.now().add(const Duration(days: 7));
        final loan = Loan(
          id: 1, dataEmprestimo: DateTime.now(), dataDevolucao: dueDate,
          status: 'ATIVO', livroId: 1, livroTitulo: 'Duna',
        );
        final result = calc(details: availableBook, loans: [loan]);
        expect(result.dueDate, dueDate);
      });

      test('dueDate deve ser null quando não há empréstimo', () {
        final result = calc(details: availableBook);
        expect(result.dueDate, isNull);
      });
    });
  });
}
