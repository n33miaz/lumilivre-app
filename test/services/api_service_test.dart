import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/models/book.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ApiService', () {
    group('singleton', () {
      test('deve retornar a mesma instância', () {
        final instance1 = ApiService();
        final instance2 = ApiService();
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('parsing do catálogo', () {
      Map<String, List<Book>> parseCatalog(List<dynamic> data) {
        Map<String, List<Book>> catalog = {};
        for (var genreData in data) {
          if (genreData['nome'] == null || genreData['livros'] == null) {
            continue;
          }
          String genreName = genreData['nome'];
          List<Book> books = (genreData['livros'] as List).map((bookData) {
            String rawImage = bookData['imagem']?.toString() ?? '';
            String finalImage = '';
            if (rawImage.isNotEmpty) {
              finalImage = rawImage.startsWith('http://')
                  ? rawImage.replaceFirst('http://', 'https://')
                  : rawImage;
            }
            return Book(
              id: (bookData['id'] as num?)?.toInt() ?? 0,
              title: bookData['titulo']?.toString() ?? 'Título Desconhecido',
              author: bookData['autor']?.toString() ?? 'Autor Desconhecido',
              imageUrl: finalImage,
              rating: (bookData['avaliacao'] as num?)?.toDouble() ?? 0.0,
            );
          }).toList();
          if (books.isNotEmpty) {
            catalog[genreName] = books;
          }
        }
        return catalog;
      }

      test('deve parsear catálogo válido com múltiplos gêneros', () {
        final catalog = parseCatalog(CatalogFixtures.validCatalog);
        expect(catalog.keys, hasLength(2));
        expect(catalog.containsKey('Ficção Científica'), isTrue);
        expect(catalog.containsKey('Romance'), isTrue);
      });

      test('deve parsear livros dentro de cada gênero', () {
        final catalog = parseCatalog(CatalogFixtures.validCatalog);
        final ficcao = catalog['Ficção Científica']!;
        expect(ficcao, hasLength(2));
        expect(ficcao[0].title, 'Duna');
        expect(ficcao[0].author, 'Frank Herbert');
        expect(ficcao[0].rating, 4.8);
        expect(ficcao[1].title, 'Fundação');
      });

      test('deve converter HTTP para HTTPS em imagens', () {
        final catalog = parseCatalog(CatalogFixtures.validCatalog);
        final fundacao = catalog['Ficção Científica']![1];
        expect(fundacao.imageUrl, startsWith('https://'));
      });

      test('deve manter HTTPS intacto', () {
        final catalog = parseCatalog(CatalogFixtures.validCatalog);
        final duna = catalog['Ficção Científica']![0];
        expect(duna.imageUrl, 'https://example.com/duna.jpg');
      });

      test('deve usar string vazia para imagem vazia', () {
        final catalog = parseCatalog(CatalogFixtures.validCatalog);
        final romance = catalog['Romance']![0];
        expect(romance.imageUrl, '');
      });

      test('deve ignorar gêneros com lista de livros vazia', () {
        expect(parseCatalog(CatalogFixtures.emptyGenre), isEmpty);
      });

      test('deve ignorar entries com nome ou livros nulos', () {
        final catalog = parseCatalog(CatalogFixtures.invalidEntries);
        expect(catalog.keys, hasLength(1));
        expect(catalog.containsKey('Válido'), isTrue);
      });

      test('deve retornar mapa vazio para lista vazia', () {
        expect(parseCatalog([]), isEmpty);
      });

      test('deve usar fallbacks para campos de livro nulos', () {
        final catalog = parseCatalog([
          {
            'nome': 'Teste',
            'livros': [
              {
                'id': null,
                'titulo': null,
                'autor': null,
                'imagem': null,
                'avaliacao': null,
              },
            ],
          },
        ]);
        final book = catalog['Teste']![0];
        expect(book.id, 0);
        expect(book.title, 'Título Desconhecido');
        expect(book.author, 'Autor Desconhecido');
        expect(book.imageUrl, '');
        expect(book.rating, 0.0);
      });
    });

    group('conversão de URL de imagem', () {
      String normalizeImageUrl(String? rawImage) {
        if (rawImage == null || rawImage.isEmpty) {
          return '';
        }
        return rawImage.startsWith('http://')
            ? rawImage.replaceFirst('http://', 'https://')
            : rawImage;
      }

      test('deve converter http:// para https://', () {
        expect(
          normalizeImageUrl('http://example.com/img.jpg'),
          'https://example.com/img.jpg',
        );
      });

      test('deve manter https:// intacto', () {
        expect(
          normalizeImageUrl('https://example.com/img.jpg'),
          'https://example.com/img.jpg',
        );
      });

      test('deve retornar vazio para null', () {
        expect(normalizeImageUrl(null), '');
      });

      test('deve retornar vazio para string vazia', () {
        expect(normalizeImageUrl(''), '');
      });

      test('deve manter URLs sem protocolo', () {
        expect(
          normalizeImageUrl('//cdn.example.com/img.jpg'),
          '//cdn.example.com/img.jpg',
        );
      });
    });
  });
}
