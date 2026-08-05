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
    late BookDetails unknownStockBook;

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
      // O que a API devolve de verdade hoje: ficha sem contagem de exemplares.
      unknownStockBook = BookDetails.fromJson({
        ...BookDetailsFixtures.validApiResponse,
        'exemplaresDisponiveis': null,
        'totalExemplares': null,
      });
    });

    LoanStatusResult calc({
      required BookDetails details,
      List<Loan>? loans,
      List<Loan>? requests,
      String targetBookId = '1',
    }) {
      return LoanStatusCalculator.calculate(
        details: details,
        loans: loans ?? [],
        requests: requests ?? [],
        targetBookId: targetBookId,
      );
    }

    /// Solicitação como ela chega em produção: `getMyRequests` mapeia a resposta
    /// da API em [Loan], e o `status` vem do `code` do enum (`PENDING`). Os testes
    /// antigos passavam mapas crus, que é justamente o formato que o cálculo
    /// nunca recebe — e por isso a checagem de pendência podia estar morta sem a
    /// suíte reclamar.
    Loan request({String bookId = '1', String status = 'PENDING'}) => Loan(
      id: 'req-$bookId',
      dataEmprestimo: DateTime.now(),
      dataDevolucao: DateTime(2100),
      status: status,
      livroId: bookId,
      livroTitulo: 'Livro solicitado',
      isRequest: true,
    );

    test(
      'deve retornar AVAILABLE quando livro tem exemplares e leitor pode emprestar',
      () {
        final result = calc(details: availableBook);
        expect(result.status, LoanStatus.available);
        expect(result.dueDate, isNull);
      },
    );

    test(
      'deve retornar ACTIVE quando leitor tem empréstimo ativo do livro',
      () {
        final loan = Loan(
          id: '1',
          dataEmprestimo: DateTime.now().subtract(const Duration(days: 5)),
          dataDevolucao: DateTime.now().add(const Duration(days: 10)),
          status: 'ATIVO',
          livroId: '1',
          livroTitulo: 'Duna',
        );
        final result = calc(details: availableBook, loans: [loan]);
        expect(result.status, LoanStatus.active);
        expect(result.dueDate, isNotNull);
      },
    );

    test('deve retornar OVERDUE quando devolução já passou', () {
      final loan = Loan(
        id: '1',
        dataEmprestimo: DateTime.now().subtract(const Duration(days: 30)),
        dataDevolucao: DateTime.now().subtract(const Duration(days: 1)),
        status: 'ATIVO',
        livroId: '1',
        livroTitulo: 'Duna',
      );
      final result = calc(details: availableBook, loans: [loan]);
      expect(result.status, LoanStatus.overdue);
    });

    test('deve retornar PENDING quando há solicitação pendente', () {
      final result = calc(details: availableBook, requests: [request()]);
      expect(result.status, LoanStatus.pending);
    });

    /// Sem isto o leitor recebe o aviso de "solicitação enviada" e continua vendo
    /// o botão convidando a solicitar o mesmo livro de novo.
    test('deve aceitar o codigo pt-BR historico de pendente', () {
      final result = calc(
        details: availableBook,
        requests: [request(status: 'PENDENTE')],
      );
      expect(result.status, LoanStatus.pending);
    });

    test('não deve considerar solicitação de outro livro', () {
      final result = calc(
        details: availableBook,
        requests: [request(bookId: '99')],
      );
      expect(result.status, LoanStatus.available);
    });

    test('não deve considerar solicitação não-pendente', () {
      final result = calc(
        details: availableBook,
        requests: [request(status: 'REJECTED')],
      );
      expect(result.status, LoanStatus.available);
    });

    test('deve retornar NO_COPIES quando totalExemplares é 0', () {
      final result = calc(details: noCopiesBook);
      expect(result.status, LoanStatus.noCopies);
    });

    test('deve retornar LIMIT_REACHED quando leitor tem 3+ empréstimos', () {
      final loans = List.generate(
        3,
        (i) => Loan(
          id: '$i',
          dataEmprestimo: DateTime.now(),
          dataDevolucao: DateTime.now().add(const Duration(days: 14)),
          status: 'ATIVO',
          livroId: '${100 + i}',
          livroTitulo: 'Livro $i',
        ),
      );
      final result = calc(details: availableBook, loans: loans);
      expect(result.status, LoanStatus.limitReached);
    });

    test('não deve bloquear com 2 empréstimos', () {
      final loans = List.generate(
        2,
        (i) => Loan(
          id: '$i',
          dataEmprestimo: DateTime.now(),
          dataDevolucao: DateTime.now().add(const Duration(days: 14)),
          status: 'ATIVO',
          livroId: '${100 + i}',
          livroTitulo: 'Livro $i',
        ),
      );
      final result = calc(details: availableBook, loans: loans);
      expect(result.status, LoanStatus.available);
    });

    test('deve retornar UNAVAILABLE quando não há exemplares disponíveis', () {
      final result = calc(details: unavailableBook);
      expect(result.status, LoanStatus.unavailable);
    });

    /// Contagem ausente não é contagem zero: a ficha que a API devolve hoje não
    /// traz exemplar nenhum, e tratar isso como "sem exemplares" travava o botão
    /// de solicitar em todos os livros do acervo.
    test('contagem desconhecida deve deixar o botão habilitado', () {
      final result = calc(details: unknownStockBook);
      expect(result.status, LoanStatus.available);
    });

    /// A penalidade saiu daqui de propósito: quem decide se ela impede o
    /// empréstimo é o servidor, no momento do pedido. O cálculo local olhava só o
    /// código da penalidade e ignorava a data de validade, então travava o botão
    /// de leitores cuja restrição já tinha vencido — e travava sem explicar nada.
    test('não deve mais bloquear pelo cadastro do leitor', () {
      final result = calc(details: availableBook);
      expect(result.status, LoanStatus.available);
    });

    group('prioridade das regras', () {
      test('empréstimo ativo deve ter prioridade sobre limite', () {
        final loans = List.generate(
          3,
          (i) => Loan(
            id: '$i',
            dataEmprestimo: DateTime.now(),
            dataDevolucao: DateTime.now().add(const Duration(days: 10)),
            status: 'ATIVO',
            livroId: i == 0 ? '1' : '${100 + i}',
            livroTitulo: 'Livro $i',
          ),
        );
        final result = calc(details: availableBook, loans: loans);
        expect(result.status, LoanStatus.active);
      });

      test('solicitação pendente deve ter prioridade sobre noCopies', () {
        final result = calc(details: noCopiesBook, requests: [request()]);
        expect(result.status, LoanStatus.pending);
      });

      test('noCopies deve ter prioridade sobre limitReached', () {
        final loans = List.generate(
          3,
          (i) => Loan(
            id: '$i',
            dataEmprestimo: DateTime.now(),
            dataDevolucao: DateTime.now().add(const Duration(days: 14)),
            status: 'ATIVO',
            livroId: '${100 + i}',
            livroTitulo: 'Livro $i',
          ),
        );
        final result = calc(details: noCopiesBook, loans: loans);
        expect(result.status, LoanStatus.noCopies);
      });
    });

    group('edge cases', () {
      test('solicitação sem livro nem status não deve crashar', () {
        final result = calc(
          details: availableBook,
          requests: [request(bookId: '', status: '')],
        );
        expect(result.status, LoanStatus.available);
      });

      test('dueDate deve ser preenchido em empréstimo ativo', () {
        final dueDate = DateTime.now().add(const Duration(days: 7));
        final loan = Loan(
          id: '1',
          dataEmprestimo: DateTime.now(),
          dataDevolucao: dueDate,
          status: 'ATIVO',
          livroId: '1',
          livroTitulo: 'Duna',
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
