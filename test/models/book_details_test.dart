import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/book_details.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('BookDetails', () {
    group('fromJson - dados completos', () {
      late BookDetails details;
      setUp(
        () => details = BookDetails.fromJson(
          BookDetailsFixtures.validApiResponse,
        ),
      );

      test('deve parsear campos de texto', () {
        expect(details.isbn, '978-3-16-148410-0');
        expect(details.nome, 'Duna');
        expect(details.autor, 'Frank Herbert');
        expect(details.editora, 'Ace Books');
        expect(details.sinopse, 'Uma saga épica no deserto.');
        expect(details.tipoCapa, 'Capa dura');
        expect(details.classificacaoEtaria, 'Livre');
        expect(details.edicao, '1');
      });

      test('deve parsear campos numéricos', () {
        expect(details.numeroPaginas, 896);
        expect(details.volume, 1);
        expect(details.exemplaresDisponiveis, 3);
        expect(details.totalExemplares, 5);
        expect(details.rating, 4.8);
      });

      test('deve parsear data como List [year, month, day]', () {
        expect(details.dataLancamento, DateTime(1965, 8, 1));
      });

      test('deve parsear gêneros como lista de strings', () {
        expect(details.generos, ['Ficção Científica', 'Aventura']);
      });

      test('deve parsear imagem', () {
        expect(details.imagem, 'https://example.com/duna.jpg');
      });
    });

    group('fromJson - dados mínimos/nulos', () {
      late BookDetails details;
      setUp(
        () => details = BookDetails.fromJson(BookDetailsFixtures.minimalData),
      );

      test('deve usar fallbacks para campos de texto nulos', () {
        expect(details.isbn, 'N/A');
        expect(details.nome, 'Título Indisponível');
        expect(details.autor, 'Autor desconhecido');
        expect(details.editora, 'Editora não informada');
        expect(details.sinopse, 'Sinopse não disponível.');
        expect(details.tipoCapa, 'Capa comum');
        expect(details.classificacaoEtaria, 'Livre');
        expect(details.edicao, 'N/A');
        expect(details.cdd, 'N/A');
      });

      test('deve usar fallbacks para campos numéricos nulos', () {
        expect(details.numeroPaginas, 0);
        expect(details.volume, isNull);
        expect(details.exemplaresDisponiveis, 0);
        expect(details.totalExemplares, 0);
        expect(details.rating, 4.6);
      });

      test('deve usar data fallback (1900-01-01) para data nula', () {
        expect(details.dataLancamento, DateTime(1900, 1, 1));
      });

      test('deve retornar lista vazia para gêneros nulos', () {
        expect(details.generos, isEmpty);
      });

      test('deve manter imagem como null', () {
        expect(details.imagem, isNull);
      });
    });

    group('parseDate', () {
      test('deve parsear data como String ISO', () {
        final d = BookDetails.fromJson({
          ...BookDetailsFixtures.minimalData,
          'dataLancamento': '2023-06-15',
        });
        expect(d.dataLancamento, DateTime(2023, 6, 15));
      });

      test('deve parsear List com apenas [year]', () {
        final d = BookDetails.fromJson({
          ...BookDetailsFixtures.minimalData,
          'dataLancamento': [2020],
        });
        expect(d.dataLancamento, DateTime(2020, 1, 1));
      });

      test('deve parsear List com [year, month]', () {
        final d = BookDetails.fromJson({
          ...BookDetailsFixtures.minimalData,
          'dataLancamento': [2020, 5],
        });
        expect(d.dataLancamento, DateTime(2020, 5, 1));
      });

      test('deve retornar fallback para data inválida', () {
        final d = BookDetails.fromJson({
          ...BookDetailsFixtures.minimalData,
          'dataLancamento': 'data-invalida',
        });
        expect(d.dataLancamento, DateTime(1900, 1, 1));
      });

      test('deve retornar fallback para List vazia', () {
        final d = BookDetails.fromJson({
          ...BookDetailsFixtures.minimalData,
          'dataLancamento': [],
        });
        expect(d.dataLancamento, DateTime(1900, 1, 1));
      });
    });

    group('generos', () {
      test('deve filtrar entries vazias da lista', () {
        final d = BookDetails.fromJson({
          ...BookDetailsFixtures.minimalData,
          'generos': ['Ficção', null, '', 'Aventura'],
        });
        expect(d.generos, ['Ficção', 'Aventura']);
      });

      test('deve converter entries numéricas para String', () {
        final d = BookDetails.fromJson({
          ...BookDetailsFixtures.minimalData,
          'generos': [1, 'Romance', 3.14],
        });
        expect(d.generos, ['1', 'Romance', '3.14']);
      });
    });

    group('bookDetailsFromJson', () {
      test('deve parsear JSON string completo', () {
        final jsonStr = json.encode(BookDetailsFixtures.validApiResponse);
        final d = bookDetailsFromJson(jsonStr);
        expect(d.isbn, '978-3-16-148410-0');
        expect(d.nome, 'Duna');
      });
    });
  });
}
