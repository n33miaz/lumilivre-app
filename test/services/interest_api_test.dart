import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/models/book_interest.dart';
import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/services/interest_api.dart';

/// Corpo real das rotas de interesse, como o T05 as fixou.
http.Response _json(Object body, int status) =>
    http.Response.bytes(utf8.encode(jsonEncode(body)), status);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const bookId = '00000000-0000-4000-8000-000000003001';

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('InterestApi — escrita', () {
    test('mark manda POST com bearer e lê o estado da resposta', () async {
      late http.Request captured;
      final api = InterestApi(
        client: MockClient((request) async {
          captured = request;
          return _json({
            'bookId': bookId,
            'interested': true,
            'markedAt': '2026-08-05T13:04:05.123-03:00',
          }, 200);
        }),
      );

      final state = await api.mark(bookId, token: 'jwt-leitor');

      expect(captured.method, 'POST');
      expect(captured.url.path, '/api/books/$bookId/interest');
      expect(captured.headers['Authorization'], 'Bearer jwt-leitor');
      expect(captured.headers['X-Client'], 'APP');
      expect(state.interested, isTrue);
      expect(state.bookId, bookId);
      expect(state.markedAt, isNotNull);
    });

    test('unmark manda DELETE e lê o corpo (não é 204)', () async {
      late http.Request captured;
      final api = InterestApi(
        client: MockClient((request) async {
          captured = request;
          return _json({
            'bookId': bookId,
            'interested': false,
            'markedAt': null,
          }, 200);
        }),
      );

      final state = await api.unmark(bookId, token: 'jwt-leitor');

      expect(captured.method, 'DELETE');
      expect(state.interested, isFalse);
      expect(state.markedAt, isNull);
    });

    /// O contrato do T05: marcar duas vezes devolve o `markedAt` da primeira, e
    /// nunca 409. O cliente não pode tratar o segundo toque como erro.
    test('marcar de novo devolve o mesmo estado, não conflito', () async {
      const markedAt = '2026-08-01T09:00:00Z';
      final api = InterestApi(
        client: MockClient(
          (request) async => _json({
            'bookId': bookId,
            'interested': true,
            'markedAt': markedAt,
          }, 200),
        ),
      );

      final first = await api.mark(bookId, token: 'jwt');
      final second = await api.mark(bookId, token: 'jwt');

      expect(second.markedAt, first.markedAt);
      expect(second.interested, isTrue);
    });

    test(
      'senha inicial pendente vira passwordChangeRequired, não falta de sessão',
      () async {
        final api = InterestApi(
          client: MockClient(
            (request) async => _json({
              'status': 403,
              'error': 'Forbidden',
              'message':
                  'Password change required before performing this action.',
              'code': 'PASSWORD_CHANGE_REQUIRED',
            }, 403),
          ),
        );

        await expectLater(
          api.mark(bookId, token: 'jwt'),
          throwsA(
            isA<ApiException>()
                .having(
                  (e) => e.requiresPasswordChange,
                  'requiresPasswordChange',
                  isTrue,
                )
                .having((e) => e.needsAuthentication, 'nao desloga', isFalse)
                // O texto é para quem depura a API, não para a tela.
                .having((e) => e.apiMessage, 'apiMessage', isNull),
          ),
        );
      },
    );

    test('401 de convidado chega como falta de sessão', () async {
      final api = InterestApi(
        client: MockClient((request) async => http.Response('', 401)),
      );

      await expectLater(
        api.mark(bookId, token: ''),
        throwsA(
          isA<ApiException>().having(
            (e) => e.failure,
            'failure',
            ApiFailure.unauthorized,
          ),
        ),
      );
    });

    test('404 de livro inexistente chega como notFound', () async {
      final api = InterestApi(
        client: MockClient((request) async => http.Response('', 404)),
      );

      await expectLater(
        api.unmark(bookId, token: 'jwt'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.failure,
            'failure',
            ApiFailure.notFound,
          ),
        ),
      );
    });

    /// Id que não é UUID (as versões antigas do app curtiam livro de id numérico)
    /// responde 400. O status precisa sobreviver: é ele que diz à migração que
    /// aquele item nunca vai subir.
    test('400 de id inválido preserva o status', () async {
      final api = InterestApi(
        client: MockClient((request) async => http.Response('', 400)),
      );

      await expectLater(
        api.mark('42', token: 'jwt'),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 400)),
      );
    });

    test('falha de socket chega como rede', () async {
      final api = InterestApi(
        client: MockClient((request) async {
          throw http.ClientException('sem rede');
        }),
      );

      await expectLater(
        api.mark(bookId, token: 'jwt'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.failure,
            'failure',
            ApiFailure.network,
          ),
        ),
      );
    });
  });

  group('InterestApi — interests/mine', () {
    test('pagina sem mandar sort e parseia o envelope do Spring', () async {
      late http.Request captured;
      final api = InterestApi(
        client: MockClient((request) async {
          captured = request;
          return _json({
            'content': [
              {
                'book': {
                  'id': bookId,
                  'title': 'Duna',
                  'author': 'Frank Herbert',
                  'coverUrl': 'https://example.com/duna.jpg',
                  'rating': 4.8,
                  'updatedAt': '2026-08-04T10:00:00Z',
                },
                'markedAt': '2026-08-05T13:04:05Z',
              },
            ],
            'number': 0,
            'last': false,
            'totalElements': 60,
          }, 200);
        }),
      );

      final page = await api.getMine(page: 0, token: 'jwt-leitor');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/api/books/interests/mine');
      expect(captured.url.queryParameters['page'], '0');
      expect(
        captured.url.queryParameters['size'],
        '${InterestApi.minePageSize}',
      );
      // A API descarta o sort do cliente nesta rota; mandar seria ruído.
      expect(captured.url.queryParameters.containsKey('sort'), isFalse);

      expect(page.items, hasLength(1));
      expect(page.items.single.book.title, 'Duna');
      expect(page.items.single.markedAt, isNotNull);
      expect(page.isLast, isFalse);
    });

    test('204 é lista vazia e fim de paginação', () async {
      final api = InterestApi(
        client: MockClient((request) async => http.Response('', 204)),
      );

      final page = await api.getMine(page: 3, token: 'jwt');

      expect(page.items, isEmpty);
      expect(page.isLast, isTrue);
      expect(page.page, 3);
    });

    test('corpo fora do contrato não vira lista vazia silenciosa', () async {
      final api = InterestApi(
        client: MockClient((request) async => _json([1, 2, 3], 200)),
      );

      await expectLater(
        api.getMine(token: 'jwt'),
        throwsA(
          isA<ApiException>().having(
            (e) => e.failure,
            'failure',
            ApiFailure.invalidResponse,
          ),
        ),
      );
    });
  });

  group('InterestApi — cache local', () {
    const book = Book(
      id: '00000000-0000-4000-8000-000000003002',
      title: 'Fundação',
      author: 'Isaac Asimov',
      imageUrl: '',
      rating: 4.7,
    );

    test('guarda e devolve a lista da conta', () async {
      final api = InterestApi();
      final items = [
        BookInterest(book: book, markedAt: DateTime(2026, 8, 2, 8, 30)),
      ];

      await api.cacheMine('2024001', items);
      final restored = await api.cachedMine('2024001');

      expect(restored, hasLength(1));
      expect(restored.single.book.title, 'Fundação');
      expect(restored.single.markedAt, DateTime(2026, 8, 2, 8, 30));
    });

    /// Dois leitores no mesmo aparelho: gravar a lista de um apaga a do outro,
    /// então a lista de quem saiu não fica no disco esperando.
    test('gravar limpa o cache das outras contas', () async {
      final api = InterestApi();

      await api.cacheMine('2024001', [BookInterest(book: book)]);
      await api.cacheMine('2024002', const []);

      expect(await api.cachedMine('2024001'), isEmpty);

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getKeys().where((k) => k.startsWith(InterestApi.cacheKeyPrefix)),
        ['${InterestApi.cacheKeyPrefix}2024002'],
      );
    });

    test('cache ilegível é tratado como ausente', () async {
      SharedPreferences.setMockInitialValues({
        '${InterestApi.cacheKeyPrefix}2024001': 'nao é json',
      });

      expect(await InterestApi().cachedMine('2024001'), isEmpty);
    });

    test('clearCache apaga tudo (é o que o logout chama)', () async {
      final api = InterestApi();
      await api.cacheMine('2024001', [BookInterest(book: book)]);

      await api.clearCache();

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getKeys().where((k) => k.startsWith(InterestApi.cacheKeyPrefix)),
        isEmpty,
      );
    });
  });
}
