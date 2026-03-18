import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/book.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Book', () {
    group('fromMap', () {
      test('deve criar Book com campos padrão da API (pt-br)', () {
        final book = Book.fromMap(BookFixtures.validApiResponse);
        expect(book.id, 1);
        expect(book.title, 'Duna');
        expect(book.author, 'Frank Herbert');
        expect(book.imageUrl, 'https://example.com/duna.jpg');
        expect(book.rating, 4.8);
      });

      test('deve criar Book com campos em inglês (fallback)', () {
        final book = Book.fromMap(BookFixtures.alternativeKeys);
        expect(book.id, 2);
        expect(book.title, 'O Senhor dos Anéis');
        expect(book.author, 'J.R.R. Tolkien');
        expect(book.imageUrl, 'https://example.com/lotr.jpg');
        expect(book.rating, 4.9);
      });

      test('deve usar valores default quando campos são nulos', () {
        final book = Book.fromMap(BookFixtures.withNullValues);
        expect(book.id, 0);
        expect(book.title, 'Título Desconhecido');
        expect(book.author, 'Autor Desconhecido');
        expect(book.imageUrl, '');
        expect(book.rating, 0.0);
      });

      test('deve usar valores default com mapa mínimo (só id)', () {
        final book = Book.fromMap(BookFixtures.minimalData);
        expect(book.id, 3);
        expect(book.title, 'Título Desconhecido');
        expect(book.author, 'Autor Desconhecido');
      });

      test('deve converter id String para int', () {
        final book = Book.fromMap(BookFixtures.withStringNumbers);
        expect(book.id, 10);
      });

      test('deve converter rating com vírgula brasileira', () {
        final book = Book.fromMap(BookFixtures.withStringNumbers);
        expect(book.rating, 4.5);
      });

      test('deve converter id double para int', () {
        final book = Book.fromMap({'id': 5.7, 'titulo': 'Test'});
        expect(book.id, 5);
      });
    });

    group('toMap / toJson', () {
      test('deve serializar corretamente para Map', () {
        const book = Book(
          id: 1,
          title: 'Duna',
          author: 'Frank Herbert',
          imageUrl: 'https://example.com/duna.jpg',
          rating: 4.8,
        );
        final map = book.toMap();
        expect(map['id'], 1);
        expect(map['title'], 'Duna');
        expect(map['author'], 'Frank Herbert');
        expect(map['imageUrl'], 'https://example.com/duna.jpg');
        expect(map['rating'], 4.8);
      });

      test('deve ser idempotente (roundtrip Map -> Book -> Map)', () {
        const original = Book(
          id: 42,
          title: 'Teste',
          author: 'Autor',
          imageUrl: 'https://img.com/x.jpg',
          rating: 3.5,
        );
        final restored = Book.fromMap(original.toMap());
        expect(restored, original);
      });

      test('deve ser idempotente (roundtrip JSON string)', () {
        const original = Book(
          id: 42,
          title: 'Teste JSON',
          author: 'Autor',
          imageUrl: 'https://img.com/j.jpg',
          rating: 4.0,
        );
        final jsonStr = original.toJson();
        final restored = Book.fromJson(jsonStr);
        expect(restored, original);
      });
    });

    group('fromJson', () {
      test('deve desserializar de JSON string', () {
        final jsonStr = json.encode(BookFixtures.alternativeKeys);
        final book = Book.fromJson(jsonStr);
        expect(book.id, 2);
        expect(book.title, 'O Senhor dos Anéis');
      });
    });

    group('equality', () {
      test('objetos com mesmos valores devem ser iguais', () {
        const book1 = Book(
          id: 1,
          title: 'A',
          author: 'B',
          imageUrl: '',
          rating: 1.0,
        );
        const book2 = Book(
          id: 1,
          title: 'A',
          author: 'B',
          imageUrl: '',
          rating: 1.0,
        );
        expect(book1, book2);
        expect(book1.hashCode, book2.hashCode);
      });

      test('objetos com valores diferentes não devem ser iguais', () {
        const book1 = Book(
          id: 1,
          title: 'A',
          author: 'B',
          imageUrl: '',
          rating: 1.0,
        );
        const book2 = Book(
          id: 2,
          title: 'A',
          author: 'B',
          imageUrl: '',
          rating: 1.0,
        );
        expect(book1, isNot(book2));
      });

      test('identical deve ser true para a mesma referência', () {
        const book = Book(
          id: 1,
          title: 'A',
          author: 'B',
          imageUrl: '',
          rating: 1.0,
        );
        // ignore: unrelated_type_equality_checks
        expect(book == book, isTrue);
      });
    });

    group('copyWith', () {
      test('deve criar cópia com campo alterado', () {
        const original = Book(
          id: 1,
          title: 'Original',
          author: 'A',
          imageUrl: '',
          rating: 3.0,
        );
        final copy = original.copyWith(title: 'Modificado', rating: 5.0);
        expect(copy.id, 1);
        expect(copy.title, 'Modificado');
        expect(copy.author, 'A');
        expect(copy.rating, 5.0);
      });

      test('deve manter valores originais quando nenhum param é passado', () {
        const original = Book(
          id: 1,
          title: 'X',
          author: 'Y',
          imageUrl: 'Z',
          rating: 2.0,
        );
        final copy = original.copyWith();
        expect(copy, original);
      });
    });

    group('conversões de tipos dinâmicos', () {
      test('deve converter bool para id como 0', () {
        final book = Book.fromMap({'id': true, 'titulo': 'Bool ID'});
        expect(book.id, 0);
      });

      test('deve converter bool para rating como 0.0', () {
        final book = Book.fromMap({'id': 1, 'avaliacao': true});
        expect(book.rating, 0.0);
      });

      test('deve tratar String inválida para id como 0', () {
        final book = Book.fromMap({'id': 'abc'});
        expect(book.id, 0);
      });

      test('deve tratar String inválida para rating como 0.0', () {
        final book = Book.fromMap({'id': 1, 'avaliacao': 'xyz'});
        expect(book.rating, 0.0);
      });
    });
  });
}
