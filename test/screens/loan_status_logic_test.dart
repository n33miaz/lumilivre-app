import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/book_details.dart';
import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/screens/book_details.dart';
import '../helpers/test_helpers.dart';

/// Testes da lógica de negócio `_calculateStatus` extraída da
/// tela [BookDetailsScreen].
///
/// Esta é a regra de negócio mais crítica do app: determina se o aluno
/// pode solicitar um empréstimo, está bloqueado, já tem o livro, etc.
///
/// Recriamos a lógica aqui de forma testável (mesma implementação)
/// já que o método original é privado (`_calculateStatus`).
///
/// TODO: Refatorar para extrair essa lógica em um use case/service
/// testável diretamente (ex: LoanStatusCalculator).
void main() {
  group('Lógica de cálculo de status do empréstimo', () {
    // Replica _calculateStatus para testes isolados
    LoanStatus calculateStatus({
      required BookDetails details,
      required List<Loan> loans,
      required List<Map<String, dynamic>> requests,
      Map<String, dynamic>? studentData,
      required int targetBookId,
    }) {
      // 1. Verifica se já tem empréstimo ativo para este livro
      final activeLoan = loans.cast<Loan?>().firstWhere(
        (l) => l!.livroId == targetBookId,
        orElse: () => null,
      );

      if (activeLoan != null) {
        return DateTime.now().isAfter(activeLoan.dataDevolucao)
            ? LoanStatus.overdue
            : LoanStatus.active;
      }

      // 2. Verifica se há solicitação pendente
      final hasPendingRequest = requests.any((r) {
        final reqLivroId = (r['livroId'] as num?)?.toInt() ?? -1;
        final reqStatus = r['status']?.toString() ?? '';
        return (reqLivroId == targetBookId) && (reqStatus == 'PENDENTE');
      });

      if (hasPendingRequest) return LoanStatus.pending;

      // 3. Verifica penalidade
      String? penalidade = studentData?['penalidade'];
      bool hasPenalty = penalidade != null && penalidade != "null";

      // 4. Contagem de empréstimos ativos
      int activeLoansCount = loans.length;

      // 5. Regras de disponibilidade
      if (details.totalExemplares == 0) return LoanStatus.noCopies;
      if (hasPenalty) return LoanStatus.blockedPenalty;
      if (activeLoansCount >= 3) return LoanStatus.limitReached;
      if (details.exemplaresDisponiveis <= 0) return LoanStatus.unavailable;

      return LoanStatus.available;
    }

    // Fixtures base
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

    // =========================================================================
    // Caso feliz: livro disponível
    // =========================================================================

    test(
      'deve retornar AVAILABLE quando livro tem exemplares e aluno pode emprestar',
      () {
        final status = calculateStatus(
          details: availableBook,
          loans: [],
          requests: [],
          studentData: {'penalidade': null},
          targetBookId: 1,
        );

        expect(status, LoanStatus.available);
      },
    );

    // =========================================================================
    // Empréstimo ativo
    // =========================================================================

    test(
      'deve retornar ACTIVE quando aluno já tem empréstimo ativo do livro',
      () {
        final futureLoan = Loan(
          id: 1,
          dataEmprestimo: DateTime.now().subtract(const Duration(days: 5)),
          dataDevolucao: DateTime.now().add(const Duration(days: 10)),
          status: 'ATIVO',
          livroId: 1,
          livroTitulo: 'Duna',
        );

        final status = calculateStatus(
          details: availableBook,
          loans: [futureLoan],
          requests: [],
          studentData: {'penalidade': null},
          targetBookId: 1,
        );

        expect(status, LoanStatus.active);
      },
    );

    // =========================================================================
    // Empréstimo atrasado
    // =========================================================================

    test('deve retornar OVERDUE quando devolução já passou', () {
      final overdueLoan = Loan(
        id: 1,
        dataEmprestimo: DateTime.now().subtract(const Duration(days: 30)),
        dataDevolucao: DateTime.now().subtract(const Duration(days: 1)),
        status: 'ATIVO',
        livroId: 1,
        livroTitulo: 'Duna',
      );

      final status = calculateStatus(
        details: availableBook,
        loans: [overdueLoan],
        requests: [],
        studentData: {'penalidade': null},
        targetBookId: 1,
      );

      expect(status, LoanStatus.overdue);
    });

    // =========================================================================
    // Solicitação pendente
    // =========================================================================

    test('deve retornar PENDING quando há solicitação pendente', () {
      final status = calculateStatus(
        details: availableBook,
        loans: [],
        requests: [
          {'livroId': 1, 'status': 'PENDENTE'},
        ],
        studentData: {'penalidade': null},
        targetBookId: 1,
      );

      expect(status, LoanStatus.pending);
    });

    test('não deve considerar solicitação de outro livro', () {
      final status = calculateStatus(
        details: availableBook,
        loans: [],
        requests: [
          {'livroId': 99, 'status': 'PENDENTE'},
        ],
        studentData: {'penalidade': null},
        targetBookId: 1,
      );

      expect(status, LoanStatus.available);
    });

    test('não deve considerar solicitação não-pendente', () {
      final status = calculateStatus(
        details: availableBook,
        loans: [],
        requests: [
          {'livroId': 1, 'status': 'REJEITADA'},
        ],
        studentData: {'penalidade': null},
        targetBookId: 1,
      );

      expect(status, LoanStatus.available);
    });

    // =========================================================================
    // Sem exemplares cadastrados
    // =========================================================================

    test('deve retornar NO_COPIES quando totalExemplares é 0', () {
      final status = calculateStatus(
        details: noCopiesBook,
        loans: [],
        requests: [],
        studentData: {'penalidade': null},
        targetBookId: 1,
      );

      expect(status, LoanStatus.noCopies);
    });

    // =========================================================================
    // Penalidade
    // =========================================================================

    test('deve retornar BLOCKED_PENALTY quando aluno tem penalidade', () {
      final status = calculateStatus(
        details: availableBook,
        loans: [],
        requests: [],
        studentData: {'penalidade': 'Multa R\$5,00'},
        targetBookId: 1,
      );

      expect(status, LoanStatus.blockedPenalty);
    });

    test('não deve considerar penalidade "null" (string)', () {
      final status = calculateStatus(
        details: availableBook,
        loans: [],
        requests: [],
        studentData: {'penalidade': 'null'},
        targetBookId: 1,
      );

      expect(status, LoanStatus.available);
    });

    // =========================================================================
    // Limite de empréstimos
    // =========================================================================

    test('deve retornar LIMIT_REACHED quando aluno tem 3+ empréstimos', () {
      final loans = List.generate(
        3,
        (i) => Loan(
          id: i,
          dataEmprestimo: DateTime.now(),
          dataDevolucao: DateTime.now().add(const Duration(days: 14)),
          status: 'ATIVO',
          livroId: 100 + i, // livros diferentes do target
          livroTitulo: 'Livro $i',
        ),
      );

      final status = calculateStatus(
        details: availableBook,
        loans: loans,
        requests: [],
        studentData: {'penalidade': null},
        targetBookId: 1,
      );

      expect(status, LoanStatus.limitReached);
    });

    test('não deve bloquear com 2 empréstimos', () {
      final loans = List.generate(
        2,
        (i) => Loan(
          id: i,
          dataEmprestimo: DateTime.now(),
          dataDevolucao: DateTime.now().add(const Duration(days: 14)),
          status: 'ATIVO',
          livroId: 100 + i,
          livroTitulo: 'Livro $i',
        ),
      );

      final status = calculateStatus(
        details: availableBook,
        loans: loans,
        requests: [],
        studentData: {'penalidade': null},
        targetBookId: 1,
      );

      expect(status, LoanStatus.available);
    });

    // =========================================================================
    // Sem exemplares disponíveis
    // =========================================================================

    test('deve retornar UNAVAILABLE quando não há exemplares disponíveis', () {
      final status = calculateStatus(
        details: unavailableBook,
        loans: [],
        requests: [],
        studentData: {'penalidade': null},
        targetBookId: 1,
      );

      expect(status, LoanStatus.unavailable);
    });

    // =========================================================================
    // Prioridade das regras (empréstimo ativo > tudo)
    // =========================================================================

    group('prioridade das regras', () {
      test('empréstimo ativo deve ter prioridade sobre penalidade', () {
        final activeLoan = Loan(
          id: 1,
          dataEmprestimo: DateTime.now(),
          dataDevolucao: DateTime.now().add(const Duration(days: 10)),
          status: 'ATIVO',
          livroId: 1,
          livroTitulo: 'Duna',
        );

        final status = calculateStatus(
          details: availableBook,
          loans: [activeLoan],
          requests: [],
          studentData: {'penalidade': 'Multa'},
          targetBookId: 1,
        );

        expect(status, LoanStatus.active);
      });

      test('solicitação pendente deve ter prioridade sobre noCopies', () {
        final status = calculateStatus(
          details: noCopiesBook,
          loans: [],
          requests: [
            {'livroId': 1, 'status': 'PENDENTE'},
          ],
          studentData: {'penalidade': null},
          targetBookId: 1,
        );

        expect(status, LoanStatus.pending);
      });

      test('noCopies deve ter prioridade sobre penalidade', () {
        final status = calculateStatus(
          details: noCopiesBook,
          loans: [],
          requests: [],
          studentData: {'penalidade': 'Multa'},
          targetBookId: 1,
        );

        expect(status, LoanStatus.noCopies);
      });

      test('penalidade deve ter prioridade sobre limitReached', () {
        final loans = List.generate(
          3,
          (i) => Loan(
            id: i,
            dataEmprestimo: DateTime.now(),
            dataDevolucao: DateTime.now().add(const Duration(days: 14)),
            status: 'ATIVO',
            livroId: 100 + i,
            livroTitulo: 'Livro $i',
          ),
        );

        final status = calculateStatus(
          details: availableBook,
          loans: loans,
          requests: [],
          studentData: {'penalidade': 'Multa'},
          targetBookId: 1,
        );

        expect(status, LoanStatus.blockedPenalty);
      });
    });

    // =========================================================================
    // Edge cases
    // =========================================================================

    group('edge cases', () {
      test('studentData null não deve crashar', () {
        final status = calculateStatus(
          details: availableBook,
          loans: [],
          requests: [],
          studentData: null,
          targetBookId: 1,
        );

        expect(status, LoanStatus.available);
      });

      test('requests com dados inválidos não devem crashar', () {
        final status = calculateStatus(
          details: availableBook,
          loans: [],
          requests: [
            {'livroId': null, 'status': null},
          ],
          studentData: {'penalidade': null},
          targetBookId: 1,
        );

        expect(status, LoanStatus.available);
      });
    });
  });
}
