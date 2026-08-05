import 'package:lumilivre/models/book_details.dart';
import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/screens/book_details.dart';

/// Resultado do cálculo de status contendo o status e a data de devolução.
class LoanStatusResult {
  final LoanStatus status;
  final DateTime? dueDate;

  const LoanStatusResult({required this.status, this.dueDate});
}

/// Calcula o status de empréstimo de um livro para um leitor.
///
/// Lógica de negócio pura, sem dependência de Flutter/widgets.
/// Prioridade das regras:
///   1. Empréstimo ativo do livro → [active] ou [overdue]
///   2. Solicitação pendente → [pending]
///   3. Sem exemplares cadastrados → [noCopies]
///   4. Limite de empréstimos (>= 3) → [limitReached]
///   5. Sem exemplares disponíveis → [unavailable]
///   6. Tudo ok → [available]
///
/// Penalidade **não** está nesta lista de propósito. Ela era avaliada aqui a
/// partir do cadastro do leitor e desabilitava o botão sem dizer por quê — a
/// informação no lugar errado e sem explicação. Quem decide se a penalidade
/// impede o empréstimo é o servidor (`RequestApprovalPolicy`), no momento do
/// pedido, e é a resposta dele que o app mostra. O estado da conta agora aparece
/// no perfil, onde pertence.
class LoanStatusCalculator {
  const LoanStatusCalculator._();

  /// Calcula o [LoanStatus] baseado nos dados do livro, empréstimos,
  static LoanStatusResult calculate({
    required BookDetails details,
    required List<Loan> loans,
    required List<Loan> requests,
    required String targetBookId,
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

    // Regras de disponibilidade. Contagem `null` é "a API não informou" — e é o
    // caso hoje, porque `BookResponse` não traz exemplar nenhum. Tratar isso como
    // zero deixava o botão morto ("sem exemplares cadastrados") em toda ficha de
    // livro; sem a contagem, quem decide é o servidor na hora do pedido.
    final total = details.totalExemplares;
    if (total != null && total == 0) {
      return const LoanStatusResult(status: LoanStatus.noCopies);
    }

    if (loans.length >= 3) {
      return const LoanStatusResult(status: LoanStatus.limitReached);
    }

    final available = details.exemplaresDisponiveis;
    if (available != null && available <= 0) {
      return const LoanStatusResult(status: LoanStatus.unavailable);
    }

    return const LoanStatusResult(status: LoanStatus.available);
  }

  static Loan? _findActiveLoan(List<Loan> loans, String targetBookId) {
    for (final loan in loans) {
      if (loan.livroId == targetBookId) {
        return loan;
      }
    }
    return null;
  }

  /// Solicitação pendente deste livro, esperando a biblioteca aprovar.
  ///
  /// Duas coisas faziam esta checagem nunca dar positivo, e o efeito era o botão
  /// continuar convidando a solicitar um livro já solicitado — logo depois de o
  /// app avisar que a solicitação foi enviada:
  ///
  /// 1. A lista que chega em produção é de [Loan] (`getMyRequests` mapeia a
  ///    resposta), mas aqui só `Map` era inspecionado — todo item caía fora. O
  ///    parâmetro era `List<dynamic>`, então nem o compilador nem os testes (que
  ///    passavam mapas) percebiam.
  /// 2. A comparação era com `PENDENTE`, o código pt-BR do enum. A API responde
  ///    `status: {code: "PENDING", label: "Pendente"}` — o nome do enum.
  static bool _hasPendingRequest(List<Loan> requests, String targetBookId) {
    return requests.any(
      (request) =>
          request.livroId == targetBookId && _isPending(request.status),
    );
  }

  /// Aceita as duas grafias porque as duas circulam: o `code` do enum
  /// (`PENDING`) e o código pt-BR histórico (`PENDENTE`), que ainda aparece em
  /// dado antigo e em fixture de teste.
  static bool _isPending(String status) {
    final normalized = status.toUpperCase();
    return normalized == 'PENDING' || normalized == 'PENDENTE';
  }
}
