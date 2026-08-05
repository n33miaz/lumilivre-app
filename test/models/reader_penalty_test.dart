import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/reader_penalty.dart';

/// A regra que estes testes fixam é a mesma de `RequestApprovalPolicy` na API:
/// só a data no futuro impede empréstimo. O app olhava apenas o código da
/// penalidade e travava o botão de leitores cuja restrição já tinha vencido.
void main() {
  Map<String, dynamic> reader({
    String? code = 'WARNING',
    String? label = 'Advertência',
    String? expiresAt,
  }) => {
    'registrationNumber': '2024008',
    'fullName': 'Leitor Teste',
    if (code != null) 'penaltyCode': {'code': code, 'label': label},
    if (expiresAt != null) 'penaltyExpiresAt': expiresAt,
  };

  String iso(Duration offset) =>
      DateTime.now().toUtc().add(offset).toIso8601String();

  group('ReaderPenalty.fromReaderJson', () {
    test('deve devolver null quando o leitor nao tem penalidade', () {
      expect(ReaderPenalty.fromReaderJson(reader(code: null)), isNull);
    });

    test('deve ler codigo, rotulo traduzido e validade', () {
      final penalty = ReaderPenalty.fromReaderJson(
        reader(expiresAt: '2026-08-10T17:25:40.068835Z'),
      );

      expect(penalty, isNotNull);
      expect(penalty!.code, 'WARNING');
      expect(penalty.label, 'Advertência');
      expect(penalty.expiresAt, isNotNull);
    });

    test('deve cair no codigo quando a API nao mandou rotulo', () {
      final penalty = ReaderPenalty.fromReaderJson(
        reader(label: null, expiresAt: iso(const Duration(days: 1))),
      );

      expect(penalty!.label, 'WARNING');
    });

    test('deve ignorar penaltyCode fora do formato esperado', () {
      expect(ReaderPenalty.fromReaderJson({'penaltyCode': 'WARNING'}), isNull);
      expect(
        ReaderPenalty.fromReaderJson({
          'penaltyCode': {'code': ''},
        }),
        isNull,
      );
    });
  });

  group('blocksLoans', () {
    test('deve bloquear enquanto a data de validade esta no futuro', () {
      final penalty = ReaderPenalty.fromReaderJson(
        reader(expiresAt: iso(const Duration(days: 3))),
      );

      expect(penalty!.blocksLoans, isTrue);
    });

    test('nao deve bloquear quando a penalidade venceu', () {
      final penalty = ReaderPenalty.fromReaderJson(
        reader(expiresAt: iso(const Duration(days: -3))),
      );

      expect(penalty, isNotNull);
      expect(penalty!.blocksLoans, isFalse);
    });

    test('nao deve bloquear penalidade registrada sem data', () {
      final penalty = ReaderPenalty.fromReaderJson(reader());

      expect(penalty, isNotNull);
      expect(penalty!.expiresAt, isNull);
      expect(penalty.blocksLoans, isFalse);
    });

    test('data ilegivel deve ser tratada como sem restricao', () {
      final penalty = ReaderPenalty.fromReaderJson(
        reader(expiresAt: 'ontem de manha'),
      );

      expect(penalty!.blocksLoans, isFalse);
    });
  });
}
