import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/loan.dart';
import 'package:lumilivre/models/loan_status_code.dart';

/// Testes do vocabulário de status e da separação das listas da aba.
///
/// As fixtures são montadas com `Loan.fromJson`/`Loan.fromRequestJson` a partir
/// do **corpo que a API manda de verdade** — `status` é objeto, com `code` no
/// nome do enum em inglês. Isso é de propósito: a rodada anterior encontrou um
/// caso em que o teste passava alimentando `Map` onde a produção recebe [Loan],
/// e por isso ficou verde sobre código morto. Aqui produção e teste percorrem o
/// mesmo `fromJson`.
void main() {
  Loan requestFromApi({required String code, String bookId = '10'}) =>
      Loan.fromRequestJson({
        'id': 'req-$code',
        'readerRegistrationNumber': '2024001',
        'bookId': bookId,
        'bookTitle': 'Livro solicitado',
        'requestedAt': '2026-04-17T10:00:00',
        'status': {'code': code, 'label': 'rótulo traduzido pelo servidor'},
      });

  Loan loanFromApi({required String code, String bookId = '20'}) =>
      Loan.fromJson({
        'id': 'loan-$code',
        'bookId': bookId,
        'bookTitle': 'Livro emprestado',
        'borrowedAt': '2026-04-01T10:00:00',
        'dueAt': '2026-04-15T10:00:00',
        'status': {'code': code, 'label': 'rótulo traduzido pelo servidor'},
      });

  group('LoanStatusCode.parse', () {
    test('reconhece o vocabulário que a API manda (nome do enum)', () {
      expect(LoanStatusCode.parse('PENDING'), LoanStatusCode.pending);
      expect(LoanStatusCode.parse('ACCEPTED'), LoanStatusCode.accepted);
      expect(LoanStatusCode.parse('REJECTED'), LoanStatusCode.rejected);
      expect(LoanStatusCode.parse('CANCELLED'), LoanStatusCode.cancelled);
      expect(LoanStatusCode.parse('ACTIVE'), LoanStatusCode.active);
      expect(LoanStatusCode.parse('COMPLETED'), LoanStatusCode.completed);
      expect(LoanStatusCode.parse('OVERDUE'), LoanStatusCode.overdue);
    });

    test('reconhece o código pt-BR dos mesmos enums', () {
      expect(LoanStatusCode.parse('PENDENTE'), LoanStatusCode.pending);
      expect(LoanStatusCode.parse('REJEITADA'), LoanStatusCode.rejected);
      expect(LoanStatusCode.parse('CANCELADA'), LoanStatusCode.cancelled);
      expect(LoanStatusCode.parse('ATIVO'), LoanStatusCode.active);
      expect(LoanStatusCode.parse('CONCLUIDO'), LoanStatusCode.completed);
      expect(LoanStatusCode.parse('ATRASADO'), LoanStatusCode.overdue);
    });

    test('normaliza caixa e espaço', () {
      expect(LoanStatusCode.parse(' pending '), LoanStatusCode.pending);
    });

    test('status desconhecido não vira status errado', () {
      expect(LoanStatusCode.parse(null), LoanStatusCode.unknown);
      expect(LoanStatusCode.parse(''), LoanStatusCode.unknown);
      expect(LoanStatusCode.parse('APROVADO'), LoanStatusCode.unknown);
    });
  });

  group('Loan.statusCode', () {
    test('lê o code de dentro do objeto de status da API', () {
      expect(
        requestFromApi(code: 'PENDING').statusCode,
        LoanStatusCode.pending,
      );
      expect(
        loanFromApi(code: 'COMPLETED').statusCode,
        LoanStatusCode.completed,
      );
    });

    /// O que quebrava o cartão do histórico: sem reconhecer `COMPLETED`, o
    /// empréstimo devolvido caía no cálculo de prazo e aparecia como atrasado.
    test('empréstimo devolvido é reconhecido como devolvido', () {
      expect(loanFromApi(code: 'COMPLETED').statusCode.isReturnedLoan, isTrue);
      expect(loanFromApi(code: 'ACTIVE').statusCode.isReturnedLoan, isFalse);
    });
  });

  group('LoanBuckets.split', () {
    /// A regressão que a tarefa nomeia: o aluno solicita e não vê nada. O filtro
    /// comparava com `PENDENTE`, a API manda `PENDING`, e a solicitação não
    /// entrava nem em "Em Andamento" nem em "Histórico".
    test('solicitação pendente entra em "Em Andamento"', () {
      final pendente = requestFromApi(code: 'PENDING');

      final buckets = LoanBuckets.split(
        activeLoans: const [],
        requests: [pendente],
      );

      expect(buckets.inProgress, [pendente]);
      expect(buckets.closedRequests, isEmpty);
    });

    test('pendentes vêm antes dos empréstimos ativos', () {
      final pendente = requestFromApi(code: 'PENDING');
      final ativo = loanFromApi(code: 'ACTIVE');

      final buckets = LoanBuckets.split(
        activeLoans: [ativo],
        requests: [pendente],
      );

      expect(buckets.inProgress, [pendente, ativo]);
    });

    test('recusada e cancelada vão para o histórico', () {
      final recusada = requestFromApi(code: 'REJECTED', bookId: '11');
      final cancelada = requestFromApi(code: 'CANCELLED', bookId: '12');

      final buckets = LoanBuckets.split(
        activeLoans: const [],
        requests: [recusada, cancelada],
      );

      expect(buckets.inProgress, isEmpty);
      expect(buckets.closedRequests, [recusada, cancelada]);
    });

    /// Aprovar a solicitação cria o empréstimo, que já chega pela rota de
    /// empréstimos do leitor. Mostrar a solicitação aceita também duplicaria o
    /// mesmo livro na aba.
    test('solicitação aceita não aparece em nenhuma das listas', () {
      final aceita = requestFromApi(code: 'ACCEPTED');
      final ativo = loanFromApi(code: 'ACTIVE');

      final buckets = LoanBuckets.split(
        activeLoans: [ativo],
        requests: [aceita],
      );

      expect(buckets.inProgress, [ativo]);
      expect(buckets.closedRequests, isEmpty);
    });

    test('status desconhecido não é inventado em nenhuma lista', () {
      final buckets = LoanBuckets.split(
        activeLoans: const [],
        requests: [requestFromApi(code: 'ALGO_NOVO')],
      );

      expect(buckets.inProgress, isEmpty);
      expect(buckets.closedRequests, isEmpty);
    });

    test('aceita o código pt-BR histórico sem mudar de lista', () {
      final buckets = LoanBuckets.split(
        activeLoans: const [],
        requests: [
          requestFromApi(code: 'PENDENTE'),
          requestFromApi(code: 'REJEITADA', bookId: '11'),
        ],
      );

      expect(buckets.inProgress, hasLength(1));
      expect(buckets.closedRequests, hasLength(1));
    });
  });
}
