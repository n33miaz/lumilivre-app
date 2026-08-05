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
          LoanStatus.limitReached,
        ]),
      );
    });

    test('deve ter exatamente 9 estados', () {
      expect(LoanStatus.values, hasLength(9));
    });

    /// Guarda de regressão do T17: penalidade não é estado de botão. Ela era
    /// avaliada no cliente a partir do cadastro do leitor, desabilitava o botão
    /// sem dizer por quê e discordava do servidor quando a restrição vencia.
    /// Agora quem recusa é a API, e a recusa vira toast.
    test('não deve existir estado de penalidade', () {
      expect(
        LoanStatus.values.map((status) => status.name),
        isNot(contains('blockedPenalty')),
      );
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

      test('limitReached deve existir para limite de 3 empréstimos', () {
        expect(LoanStatus.limitReached, isNotNull);
      });

      test('noCopies deve existir para livros sem exemplares cadastrados', () {
        expect(LoanStatus.noCopies, isNotNull);
      });
    });
  });
}
