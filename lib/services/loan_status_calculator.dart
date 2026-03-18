import 'package:lumilivre/models/book_details.dart';
import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/screens/book_details.dart';

/// Resultado do cálculo de status contendo o status e a data de devolução.
class LoanStatusResult {
  final LoanStatus status;
  final DateTime? dueDate;

  const LoanStatusResult({required this.status, this.dueDate});
}

/// Calcula o status de empréstimo de um livro para um aluno.
///
/// Lógica de negócio pura, sem dependência de Flutter/widgets.
/// Prioridade das regras:
///   1. Empréstimo ativo do livro → [active] ou [overdue]
///   2. Solicitação pendente → [pending]
///   3. Sem exemplares cadastrados → [noCopies]
///   4. Penalidade → [blockedPenalty]
///   5. Limite de empréstimos (>= 3) → [limitReached]
///   6. Sem exemplares disponíveis → [unavailable]
///   7. Tudo ok → [available]
class LoanStatusCalculator {
  const LoanStatusCalculator._();

  /// Calcula o [LoanStatus] baseado nos dados do livro, empréstimos,
  static LoanStatusResult calculate({
    required BookDetails details,
    required List<Loan> loans,
    required List<dynamic> requests,
    required int targetBookId,
    Map<String, dynamic>? studentData,
  }) {
    // Verifica empréstimo ativo para este livro
    final activeLoan = _findActiveLoan(loans, targetBookId);
    if (activeLoan != null) {
      final isOverdue = DateTime.now().isAfter(activeLoan.dataDevolucao);
      return LoanStatusResult(
        status: isOverdue ? LoanStatus.overdue : LoanStatus.active,
        dueDate: activeLoan.dataDevolucao,
      );
    }

    // Verifica solicitação pendente
    if (_hasPendingRequest(requests, targetBookId)) {
      return const LoanStatusResult(status: LoanStatus.pending);
    }

    // Regras de disponibilidade
    if (details.totalExemplares == 0) {
      return const LoanStatusResult(status: LoanStatus.noCopies);
    }

    final penalidade = studentData?['penalidade'];
    final hasPenalty = penalidade != null && penalidade != 'null';
    if (hasPenalty) {
      return const LoanStatusResult(status: LoanStatus.blockedPenalty);
    }

    if (loans.length >= 3) {
      return const LoanStatusResult(status: LoanStatus.limitReached);
    }

    if (details.exemplaresDisponiveis <= 0) {
      return const LoanStatusResult(status: LoanStatus.unavailable);
    }

    return const LoanStatusResult(status: LoanStatus.available);
  }

  static Loan? _findActiveLoan(List<Loan> loans, int targetBookId) {
    for (final loan in loans) {
      if (loan.livroId == targetBookId) { return loan; }
    }
    return null;
  }

  static bool _hasPendingRequest(List<dynamic> requests, int targetBookId) {
    return requests.any((r) {
      if (r == null || r is! Map) { return false; }
      final reqLivroId = (r['livroId'] as num?)?.toInt() ?? -1;
      final reqStatus = r['status']?.toString() ?? '';
      return reqLivroId == targetBookId && reqStatus == 'PENDENTE';
    });
  }
}
