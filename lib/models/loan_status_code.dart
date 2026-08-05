import 'loan.dart';

/// Vocabulário de status que a API usa para empréstimo e para solicitação.
///
/// A API serializa status como objeto — `status: {code: "PENDING", label:
/// "Pendente"}` — e o `code` é o `name()` do enum Java (`LocalizedEnum.of`), ou
/// seja: **inglês**. O app comparava com o código pt-BR do mesmo enum
/// (`PENDENTE`, `REJEITADA`, `CONCLUIDO`), então nenhuma dessas comparações
/// casava. Duas telas ficaram mentindo por causa disso:
///
/// - A solicitação pendente não entrava em "Em Andamento" nem em "Histórico": o
///   aluno pedia o livro e não via absolutamente nada.
/// - Todo item do histórico caía no cálculo de prazo do cartão e aparecia em
///   vermelho como "Atrasado (N dias)" — porque a devolução de um empréstimo já
///   concluído está, por definição, no passado.
///
/// O enum vive num lugar só porque comparação de status errada é invisível: não
/// quebra build, não quebra teste, só apaga informação da tela.
enum LoanStatusCode {
  active,
  completed,
  overdue,
  pending,
  accepted,
  rejected,
  cancelled,
  unknown;

  /// Traduz o código cru em status conhecido.
  ///
  /// Aceita as duas grafias de propósito, e o motivo não é superstição: os enums
  /// da API carregam os dois vocabulários (`LoanStatus.ACTIVE` tem o código
  /// pt-BR `ATIVO`, e `LoanStatus.fromPtBrCode` aceita qualquer um dos dois na
  /// entrada). O pt-BR portanto circula — em dado gravado por versão antiga do
  /// app, no cache local do próprio aparelho e nas fixtures de teste. Uma
  /// resposta que não se reconhece vira [unknown], nunca um status errado.
  static LoanStatusCode parse(String? raw) {
    final normalized = raw?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return LoanStatusCode.unknown;
    }
    return _codeVocabulary[normalized] ?? LoanStatusCode.unknown;
  }

  /// Solicitação que a biblioteca ainda não respondeu.
  bool get isOpenRequest => this == pending;

  /// Solicitação que terminou sem virar empréstimo.
  ///
  /// `CANCELLED` e `REJECTED` andam juntos porque a diferença entre "a
  /// biblioteca recusou" e "foi cancelada" não tem, hoje, quem a produza pelo
  /// app: nenhum fluxo do servidor grava `CANCELLED` (só o seed de demonstração
  /// tem registros assim) e o leitor não cancela solicitação em tela nenhuma. Um
  /// texto próprio para esse estado seria copy que ninguém alcança; o que
  /// importava era ele não desaparecer da lista, como desaparecia.
  bool get isClosedRequest => this == rejected || this == cancelled;

  /// Empréstimo devolvido.
  bool get isReturnedLoan => this == completed;
}

/// As duas grafias que a API pode mandar, achatadas em maiúsculas.
const Map<String, LoanStatusCode> _codeVocabulary = {
  'ACTIVE': LoanStatusCode.active,
  'ATIVO': LoanStatusCode.active,
  'COMPLETED': LoanStatusCode.completed,
  'CONCLUIDO': LoanStatusCode.completed,
  'OVERDUE': LoanStatusCode.overdue,
  'ATRASADO': LoanStatusCode.overdue,
  'PENDING': LoanStatusCode.pending,
  'PENDENTE': LoanStatusCode.pending,
  'ACCEPTED': LoanStatusCode.accepted,
  'ACEITA': LoanStatusCode.accepted,
  'REJECTED': LoanStatusCode.rejected,
  'REJEITADA': LoanStatusCode.rejected,
  'CANCELLED': LoanStatusCode.cancelled,
  'CANCELADA': LoanStatusCode.cancelled,
};

extension LoanStatusReading on Loan {
  /// Status do empréstimo/solicitação já traduzido para o enum do app.
  LoanStatusCode get statusCode => LoanStatusCode.parse(status);
}

/// As duas listas da aba de empréstimos do perfil.
///
/// A separação mora aqui, e não na tela, porque ela é a regra que estava errada:
/// enquanto o filtro comparava com `PENDENTE`, `_activeList` recebia apenas os
/// empréstimos e a solicitação recém-enviada não aparecia em lugar nenhum.
class LoanBuckets {
  const LoanBuckets({required this.inProgress, required this.closedRequests});

  /// Solicitações à espera de aprovação, seguidas dos empréstimos ativos.
  final List<Loan> inProgress;

  /// Solicitações recusadas ou canceladas — histórico, mas não empréstimo.
  ///
  /// Ficam separadas do histórico de empréstimos porque vêm de outra rota
  /// (`/api/loan-requests/reader/{matricula}`, carregada junto com a aba "Em
  /// Andamento") e são poucas: paginá-las junto obrigaria as duas rotas a
  /// terminar antes de a primeira página existir.
  final List<Loan> closedRequests;

  /// Distribui empréstimos ativos e solicitações nas listas da tela.
  ///
  /// A solicitação `ACCEPTED` fica fora das duas de propósito: aprovar cria o
  /// empréstimo, que já chega por `GET /api/loans/reader/{matricula}`. Mostrar
  /// também a solicitação aceita duplicaria o mesmo livro em "Em Andamento".
  factory LoanBuckets.split({
    required List<Loan> activeLoans,
    required List<Loan> requests,
  }) {
    final pending = <Loan>[];
    final closed = <Loan>[];

    for (final request in requests) {
      final code = request.statusCode;
      if (code.isOpenRequest) {
        pending.add(request);
      } else if (code.isClosedRequest) {
        closed.add(request);
      }
    }

    return LoanBuckets(
      inProgress: [...pending, ...activeLoans],
      closedRequests: closed,
    );
  }
}
