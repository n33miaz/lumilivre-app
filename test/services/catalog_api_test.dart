import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lumilivre/services/auth_storage.dart';
import 'package:lumilivre/services/catalog_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Envelope `Page` do Spring, como a API devolve nas rotas paginadas.
  String pageBody({
    required List<Map<String, dynamic>> content,
    required bool last,
    int number = 0,
  }) => jsonEncode({
    'content': content,
    'number': number,
    'size': content.length,
    'totalElements': content.length,
    'totalPages': 1,
    'last': last,
    'first': number == 0,
    'empty': content.isEmpty,
  });

  const livro = {
    'id': '00000000-0000-4000-8000-000000003020',
    'title': 'The Hobbit',
    'author': 'J.R.R. Tolkien',
    'coverUrl': 'https://example.com/hobbit.jpg',
    'rating': 4.7,
  };

  group('CatalogApi', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
    });

    test(
      'getCatalogLocal deve retornar null quando cache nao existe',
      () async {
        final catalog = await CatalogApi().getCatalogLocal();

        expect(catalog, isNull);
      },
    );

    test('getCatalogLocal deve parsear cache valido', () async {
      SharedPreferences.setMockInitialValues({
        'catalog_cache_v2_pt-BR': '''
          [
            {
              "nome": "Ficcao",
              "livros": [
                {
                  "id": 1,
                  "titulo": "Duna",
                  "autor": "Frank Herbert",
                  "imagem": "http://example.com/duna.jpg",
                  "avaliacao": 4.8
                }
              ]
            }
          ]
        ''',
      });

      final catalog = await CatalogApi().getCatalogLocal();

      expect(catalog, isNotNull);
      expect(catalog!.keys, contains('Ficcao'));
      expect(catalog['Ficcao']!.single.title, 'Duna');
      expect(
        catalog['Ficcao']!.single.imageUrl,
        'https://example.com/duna.jpg',
      );
    });

    test('getCatalogLocal deve retornar null para cache invalido', () async {
      SharedPreferences.setMockInitialValues({
        'catalog_cache_v2_pt-BR': '{json invalido',
      });

      final catalog = await CatalogApi().getCatalogLocal();

      expect(catalog, isNull);
    });

    /// Modo convidado: o token continua gravado no armazenamento seguro (o T15
    /// deixa a sessão lá de propósito, para nova tentativa de biometria). Se o
    /// serviço buscar o token por conta própria, a requisição sai autenticada com
    /// uma sessão que a UI não reconhece — a tela diz "Convidado" e o
    /// `access_log` da API registra o leitor.
    group('token do chamador, nunca do armazenamento seguro', () {
      setUp(() {
        FlutterSecureStorage.setMockInitialValues({
          AuthStorage.authTokenKey: 'jwt-de-sessao-travada',
          AuthStorage.userDataKey:
              '{"id":1,"email":"leitor@escola.com","role":"READER",'
              '"readerRegistrationNumber":"2024001",'
              '"token":"jwt-de-sessao-travada","isInitialPassword":false}',
        });
      });

      test('fetchAndSaveCatalog sem token nao manda Authorization', () async {
        late http.Request captured;
        final api = CatalogApi(
          client: MockClient((request) async {
            captured = request;
            return http.Response.bytes(utf8.encode('[]'), 200);
          }),
        );

        await api.fetchAndSaveCatalog();

        expect(captured.headers.containsKey('Authorization'), isFalse);
      });

      test('searchBooks sem token nao manda Authorization', () async {
        late http.Request captured;
        final api = CatalogApi(
          client: MockClient((request) async {
            captured = request;
            return http.Response.bytes(
              utf8.encode(pageBody(content: const [livro], last: true)),
              200,
            );
          }),
        );

        await api.searchBooks('hobbit');

        expect(captured.headers.containsKey('Authorization'), isFalse);
      });

      test('getBooksByGenre sem token nao manda Authorization', () async {
        late http.Request captured;
        final api = CatalogApi(
          client: MockClient((request) async {
            captured = request;
            return http.Response.bytes(
              utf8.encode(pageBody(content: const [livro], last: true)),
              200,
            );
          }),
        );

        await api.getBooksByGenre('Fantasia');

        expect(captured.headers.containsKey('Authorization'), isFalse);
      });

      test('token do chamador vai no Authorization', () async {
        final capturadas = <http.BaseRequest>[];
        final api = CatalogApi(
          client: MockClient((request) async {
            capturadas.add(request);
            return http.Response.bytes(
              utf8.encode(pageBody(content: const [livro], last: true)),
              200,
            );
          }),
        );

        await api.getBooksByGenre('Fantasia', token: 'jwt-da-sessao-viva');
        await api.searchBooks('hobbit', token: 'jwt-da-sessao-viva');

        for (final request in capturadas) {
          expect(request.headers['Authorization'], 'Bearer jwt-da-sessao-viva');
        }
      });
    });

    group('paginação por gênero', () {
      test('pede ordenação estável, sem a qual paginar repete livro', () async {
        late http.Request captured;
        final api = CatalogApi(
          client: MockClient((request) async {
            captured = request;
            return http.Response.bytes(
              utf8.encode(pageBody(content: const [livro], last: true)),
              200,
            );
          }),
        );

        await api.getBooksByGenre('Fantasia', page: 2);

        final params = captured.url.queryParametersAll;
        expect(captured.url.path, endsWith('/api/books/genres/Fantasia'));
        expect(params['page'], ['2']);
        expect(params['size'], ['10']);
        // Título como ordem e id como desempate: a consulta da API não tem
        // `ORDER BY` próprio.
        expect(params['sort'], ['title,asc', 'id,asc']);
      });

      test('fim da lista vem do last do envelope', () async {
        final api = CatalogApi(
          client: MockClient(
            (request) async => http.Response.bytes(
              utf8.encode(
                pageBody(content: const [livro], last: false, number: 1),
              ),
              200,
            ),
          ),
        );

        final page = await api.getBooksByGenre('Fantasia', page: 1);

        expect(page.items, hasLength(1));
        expect(page.items.single.title, 'The Hobbit');
        expect(page.page, 1);
        expect(page.isLast, isFalse);
      });

      test('204 da API vira página vazia e final', () async {
        final api = CatalogApi(
          client: MockClient((request) async => http.Response('', 204)),
        );

        final page = await api.getBooksByGenre('Fantasia', page: 9);

        expect(page.items, isEmpty);
        expect(page.isLast, isTrue);
        expect(page.page, 9);
      });
    });
  });
}
