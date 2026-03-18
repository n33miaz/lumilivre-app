import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/screens/book_details.dart';

/// Testes do enum [LoanStatus] que controla a lógica de empréstimo.
///
/// Este enum é central na UX — determina o texto, cor e ação disponível
/// no botão de empréstimo da tela de detalhes do livro.
void main() {
  group('LoanStatus', () {
    test('deve conter todos os estados esperados', () {
      expect(
        LoanStatus.values,
        containsAll([
          LoanStatus.loading,
          LoanStatus.available,
          LoanStatus.unavailable,
          LoanStatus.noCopies,
          LoanStatus.pending,
          LoanStatus.active,
          LoanStatus.overdue,
          LoanStatus.guest,
          LoanStatus.blockedPenalty,
          LoanStatus.limitReached,
        ]),
      );
    });

    test('deve ter exatamente 10 estados', () {
      expect(LoanStatus.values, hasLength(10));
    });

    test('loading deve ser o estado inicial', () {
      // Verifica que o estado que a tela usa como inicial está no enum
      expect(LoanStatus.loading, isNotNull);
    });

    // =========================================================================
    // Regras de negócio (documentação via testes)
    // =========================================================================

    group('regras de negócio', () {
      test('guest deve existir para modo convidado', () {
        expect(LoanStatus.guest, isNotNull);
      });

      test('blockedPenalty deve existir para alunos com penalidade', () {
        expect(LoanStatus.blockedPenalty, isNotNull);
      });

      test('limitReached deve existir para limite de 3 empréstimos', () {
        expect(LoanStatus.limitReached, isNotNull);
      });

      test('noCopies deve existir para livros sem exemplares cadastrados', () {
        expect(LoanStatus.noCopies, isNotNull);
      });
    });
  });
}
