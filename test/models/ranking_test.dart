import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/ranking.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('RankingItem', () {
    group('fromJson', () {
      test('deve criar RankingItem com dados válidos', () {
        final item = RankingItem.fromJson(RankingFixtures.validItem);
        expect(item.matricula, '2025001');
        expect(item.nome, 'João Silva');
        expect(item.emprestimosCount, 15);
      });

      test('deve usar fallbacks para campos nulos', () {
        final item = RankingItem.fromJson(RankingFixtures.minimalItem);
        expect(item.matricula, '');
        expect(item.nome, 'Aluno');
        expect(item.emprestimosCount, 0);
      });

      test('deve criar lista de RankingItem a partir de lista JSON', () {
        final items = [
          RankingFixtures.validItem,
          {
            ...RankingFixtures.validItem,
            'nome': 'Maria',
            'emprestimosCount': 20,
          },
        ].map((e) => RankingItem.fromJson(e)).toList();
        expect(items, hasLength(2));
        expect(items[0].nome, 'João Silva');
        expect(items[1].emprestimosCount, 20);
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
