import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/ranking.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('RankingItem', () {
    group('fromJson', () {
      test('deve criar RankingItem com dados válidos', () {
        final item = RankingItem.fromJson(RankingFixtures.validItem);
        expect(item.registrationNumber, '2025001');
        expect(item.fullName, 'João Silva');
        expect(item.loanCount, 15);
      });

      test('deve aceitar as chaves legadas em português', () {
        final item = RankingItem.fromJson(RankingFixtures.legacyItem);
        expect(item.registrationNumber, '2025001');
        expect(item.fullName, 'João Silva');
        expect(item.loanCount, 15);
      });

      test('deve usar fallbacks para campos nulos', () {
        final item = RankingItem.fromJson(RankingFixtures.minimalItem);
        expect(item.registrationNumber, '');
        expect(item.fullName, 'Leitor');
        expect(item.loanCount, 0);
      });

      test('deve criar lista de RankingItem a partir de lista JSON', () {
        final items = [
          RankingFixtures.validItem,
          {...RankingFixtures.validItem, 'fullName': 'Maria', 'loanCount': 20},
        ].map((e) => RankingItem.fromJson(e)).toList();
        expect(items, hasLength(2));
        expect(items[0].fullName, 'João Silva');
        expect(items[1].loanCount, 20);
      });
    });
  });

  group('FilterItem', () {
    group('fromJson', () {
      test('deve criar FilterItem com id int', () {
        final item = FilterItem.fromJson({'id': 5, 'nome': 'Informática'});
        expect(item.id, 5);
        expect(item.nome, 'Informática');
      });

      test('deve converter id String para int', () {
        final item = FilterItem.fromJson({'id': '10', 'nome': 'Eletrônica'});
        expect(item.id, 10);
      });

      test('deve usar 0 para id inválido', () {
        final item = FilterItem.fromJson({'id': 'abc', 'nome': 'Teste'});
        expect(item.id, 0);
      });

      test('deve usar string vazia para nome null', () {
        final item = FilterItem.fromJson({'id': 1, 'nome': null});
        expect(item.nome, '');
      });
    });
  });
}
