import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/models/book_interest.dart';
import 'package:lumilivre/models/paged_result.dart';
import 'package:lumilivre/models/user.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/services/interest_api.dart';
import 'package:lumilivre/services/legacy_favorites_store.dart';

/// Sessão sem rede: o provider só precisa do token e da conta, e é o
/// `AuthProvider` quem responde os dois.
class _FakeAuth extends AuthProvider {
  _FakeAuth({this.session});

  LoginResponse? session;

  @override
  LoginResponse? get user => session;

  @override
  bool get isAuthenticated => session != null;

  @override
  String? get sessionToken => session?.token;
}

/// Dublê das três rotas de interesse. O cache local e a chave antiga continuam
/// sendo os de verdade (sobre `SharedPreferences` mockado), porque é justamente o
/// que esta tarefa mudou de lugar.
class _FakeInterestApi extends InterestApi {
  final List<String> marked = <String>[];
  final List<String> unmarked = <String>[];
  final Map<int, PagedResult<BookInterest>> pages =
      <int, PagedResult<BookInterest>>{};

  /// Falha a próxima escrita (qualquer livro).
  ApiException? writeFailure;

  /// Falha a escrita de um livro específico — usado pela migração.
  final Map<String, ApiException> writeFailureByBook = <String, ApiException>{};

  ApiException? mineFailure;

  /// Segura o `mark` até alguém completar, para testar o toque duplo.
  Completer<void>? markGate;

  @override
  Future<InterestState> mark(String bookId, {required String token}) async {
    marked.add(bookId);
    final gate = markGate;
    if (gate != null) {
      await gate.future;
    }
    final failure = writeFailureByBook[bookId] ?? writeFailure;
    if (failure != null) {
      throw failure;
    }
    return InterestState(
      bookId: bookId,
      interested: true,
      markedAt: DateTime(2026, 8, 5, 10),
    );
  }

  @override
  Future<InterestState> unmark(String bookId, {required String token}) async {
    unmarked.add(bookId);
    final failure = writeFailureByBook[bookId] ?? writeFailure;
    if (failure != null) {
      throw failure;
    }
    return InterestState(bookId: bookId, interested: false);
  }

  @override
  Future<PagedResult<BookInterest>> getMine({
    int page = 0,
    required String token,
  }) async {
    final failure = mineFailure;
    if (failure != null) {
      throw failure;
    }
    return pages[page] ?? PagedResult<BookInterest>.empty(page: page);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const bookA = Book(
    id: 'aaaaaaaa-0000-4000-8000-000000000001',
    title: 'Livro A',
    author: 'Autor A',
    imageUrl: '',
    rating: 4.0,
  );
  const bookB = Book(
    id: 'bbbbbbbb-0000-4000-8000-000000000002',
    title: 'Livro B',
    author: 'Autor B',
    imageUrl: '',
    rating: 3.5,
  );

  LoginResponse reader({
    String token = 'jwt-leitor',
    String matricula = '2024001',
  }) => LoginResponse(
    id: '7',
    email: 'leitor@escola.com',
    role: 'READER',
    readerRegistrationNumber: matricula,
    token: token,
    isInitialPassword: false,
  );

  PagedResult<BookInterest> pageOf(
    List<Book> books, {
    int page = 0,
    bool isLast = true,
  }) => PagedResult<BookInterest>(
    items: books
        .map(
          (book) =>
              BookInterest(book: book, markedAt: DateTime(2026, 8, 1, 12)),
        )
        .toList(),
    page: page,
    isLast: isLast,
  );

  late _FakeInterestApi api;
  late FavoritesProvider provider;

  /// Entra na conta e espera o provider terminar de acordar (cache, servidor e
  /// migração da lista antiga).
  Future<_FakeAuth> signIn({String token = 'jwt-leitor'}) async {
    final auth = _FakeAuth(session: reader(token: token));
    provider.syncWithAuth(auth);
    await pumpEventQueue();
    return auth;
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    api = _FakeInterestApi();
    provider = FavoritesProvider(api: api, legacyStore: LegacyFavoritesStore());
  });

  group('sessão', () {
    test('sem leitor identificado não busca nada e nenhum coração acende', () {
      provider.syncWithAuth(_FakeAuth());

      expect(provider.hasSession, isFalse);
      expect(provider.interests, isEmpty);
      expect(provider.isFavorite(bookA.id), isFalse);
    });

    test('convidado não pode marcar: recusa sem chamar a API', () async {
      provider.syncWithAuth(_FakeAuth());

      expect(await provider.toggle(bookA), ApiFailure.unauthorized);
      expect(api.marked, isEmpty);
    });

    test('ao entrar, a lista vem do servidor', () async {
      api.pages[0] = pageOf([bookA, bookB]);

      await signIn();

      expect(provider.interests.map((i) => i.book.id), [bookA.id, bookB.id]);
      expect(provider.isFavorite(bookA.id), isTrue);
      expect(provider.isStale, isFalse);
    });

    test('logout esquece a lista e o cache do aparelho', () async {
      api.pages[0] = pageOf([bookA]);
      final auth = await signIn();
      expect(provider.interests, isNotEmpty);

      auth.session = null;
      provider.syncWithAuth(auth);
      await pumpEventQueue();

      expect(provider.interests, isEmpty);
      expect(provider.hasSession, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getKeys().where((k) => k.startsWith(InterestApi.cacheKeyPrefix)),
        isEmpty,
      );
    });

    test('token novo da mesma conta não recarrega a lista', () async {
      api.pages[0] = pageOf([bookA]);
      final auth = await signIn();

      // Troca de senha emite token novo; a lista é a mesma.
      auth.session = reader(token: 'jwt-novo');
      provider.syncWithAuth(auth);
      await pumpEventQueue();

      expect(provider.interests, hasLength(1));
      expect(await provider.toggle(bookB), isNull);
    });
  });

  group('marcar e desmarcar', () {
    test(
      'pinta o coração antes da resposta e mantém quando confirma',
      () async {
        await signIn();
        api.markGate = Completer<void>();

        final pending = provider.toggle(bookA);
        expect(
          provider.isFavorite(bookA.id),
          isTrue,
          reason: 'pintura otimista: o coração reage ao toque',
        );
        expect(provider.isPending(bookA.id), isTrue);

        api.markGate!.complete();
        expect(await pending, isNull);

        expect(provider.isFavorite(bookA.id), isTrue);
        expect(provider.isPending(bookA.id), isFalse);
        expect(provider.interests.first.markedAt, DateTime(2026, 8, 5, 10));
      },
    );

    test('sem rede o coração NÃO fica preenchido', () async {
      await signIn();
      api.writeFailure = const ApiException(ApiFailure.network);

      expect(await provider.toggle(bookA), ApiFailure.network);
      expect(
        provider.isFavorite(bookA.id),
        isFalse,
        reason: 'o que o servidor não aceitou não fica na tela',
      );
      expect(provider.interests, isEmpty);
    });

    test('senha inicial pendente não desloga, e desfaz a pintura', () async {
      await signIn();
      api.writeFailure = const ApiException(
        ApiFailure.passwordChangeRequired,
        statusCode: 403,
      );

      expect(await provider.toggle(bookA), ApiFailure.passwordChangeRequired);
      expect(provider.isFavorite(bookA.id), isFalse);
      expect(
        provider.hasSession,
        isTrue,
        reason: '403 de senha pendente não é falta de sessão',
      );
    });

    test('desmarcar recusado devolve o livro ao lugar em que estava', () async {
      api.pages[0] = pageOf([bookA, bookB]);
      await signIn();
      api.writeFailure = const ApiException(ApiFailure.network);

      expect(await provider.toggle(bookB), ApiFailure.network);
      expect(provider.interests.map((i) => i.book.id), [bookA.id, bookB.id]);
      expect(provider.isFavorite(bookB.id), isTrue);
    });

    test('desmarcar confirmado tira o livro da lista', () async {
      api.pages[0] = pageOf([bookA, bookB]);
      await signIn();

      expect(await provider.toggle(bookA), isNull);
      expect(api.unmarked, [bookA.id]);
      expect(provider.interests.map((i) => i.book.id), [bookB.id]);
    });

    test('segundo toque durante a escrita não abre outra requisição', () async {
      await signIn();
      api.markGate = Completer<void>();

      final first = provider.toggle(bookA);
      final second = provider.toggle(bookA);
      api.markGate!.complete();
      await Future.wait([first, second]);

      expect(api.marked, [bookA.id]);
      expect(api.unmarked, isEmpty);
      expect(provider.isFavorite(bookA.id), isTrue);
    });

    test('o estado adotado é o do corpo da resposta', () async {
      await signIn();

      await provider.toggle(bookA);

      // `markedAt` do servidor, não o `DateTime.now()` da pintura otimista.
      expect(provider.interests.single.markedAt, DateTime(2026, 8, 5, 10));
    });
  });

  group('cache local', () {
    test('abre offline com a lista guardada e assume que está velha', () async {
      SharedPreferences.setMockInitialValues({
        '${InterestApi.cacheKeyPrefix}2024001': json.encode([
          BookInterest(book: bookA, markedAt: DateTime(2026, 7, 1)).toMap(),
        ]),
      });
      api.mineFailure = const ApiException(ApiFailure.network);

      await signIn();

      expect(provider.interests.map((i) => i.book.id), [bookA.id]);
      expect(provider.isFavorite(bookA.id), isTrue);
      expect(provider.isStale, isTrue);
      expect(provider.failed, isTrue);
    });

    test('cache de outra conta não aparece para quem entrou', () async {
      SharedPreferences.setMockInitialValues({
        '${InterestApi.cacheKeyPrefix}9999999': json.encode([
          BookInterest(book: bookB, markedAt: DateTime(2026, 7, 1)).toMap(),
        ]),
      });
      api.mineFailure = const ApiException(ApiFailure.network);

      await signIn();

      expect(provider.interests, isEmpty);
    });

    test('a resposta do servidor substitui o cache', () async {
      SharedPreferences.setMockInitialValues({
        '${InterestApi.cacheKeyPrefix}2024001': json.encode([
          BookInterest(book: bookA, markedAt: DateTime(2026, 7, 1)).toMap(),
        ]),
      });
      api.pages[0] = pageOf([bookB]);

      await signIn();

      expect(provider.interests.map((i) => i.book.id), [bookB.id]);
      expect(provider.isFavorite(bookA.id), isFalse);
      expect(provider.isStale, isFalse);
    });
  });

  group('paginação', () {
    test(
      'ensureLoaded busca as páginas seguintes até o servidor dizer que acabou',
      () async {
        api.pages[0] = pageOf([bookA], isLast: false);
        api.pages[1] = pageOf([bookB], page: 1);
        await signIn();

        expect(provider.interests, hasLength(1));
        expect(provider.hasMore, isTrue);

        await provider.ensureLoaded();

        expect(provider.interests.map((i) => i.book.id), [bookA.id, bookB.id]);
        expect(provider.hasMore, isFalse);
      },
    );

    test('falha de página guarda o motivo sem apagar o que já veio', () async {
      api.pages[0] = pageOf([bookA], isLast: false);
      await signIn();

      api.mineFailure = const ApiException(ApiFailure.network);
      await provider.loadMore();

      expect(provider.interests, hasLength(1));
      expect(provider.failed, isTrue);
      expect(provider.lastFailure, ApiFailure.network);
    });
  });

  group('migração da lista que estava no aparelho', () {
    /// Como as versões antigas gravavam: uma lista de JSON de `Book`.
    List<String> legacy(List<Book> books) =>
        books.map((book) => book.toJson()).toList();

    test(
      'sobe o que estava local, avisa quantos e apaga a chave antiga',
      () async {
        SharedPreferences.setMockInitialValues({
          LegacyFavoritesStore.favoritesKey: legacy([bookA, bookB]),
        });

        await signIn();

        expect(api.marked, containsAll([bookA.id, bookB.id]));
        expect(provider.interests, hasLength(2));
        expect(provider.migrationNotice, 2);

        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList(LegacyFavoritesStore.favoritesKey), isNull);
        expect(prefs.getBool(LegacyFavoritesStore.doneKey), isTrue);
      },
    );

    test('roda uma vez só: a segunda sessão não reenvia nada', () async {
      SharedPreferences.setMockInitialValues({
        LegacyFavoritesStore.favoritesKey: legacy([bookA]),
      });
      await signIn();
      expect(api.marked, [bookA.id]);

      final other = FavoritesProvider(
        api: api,
        legacyStore: LegacyFavoritesStore(),
      );
      other.syncWithAuth(_FakeAuth(session: reader()));
      await pumpEventQueue();

      expect(api.marked, [bookA.id]);
      expect(other.migrationNotice, isNull);
    });

    test('o que a conta já tem não é reenviado nem contado', () async {
      SharedPreferences.setMockInitialValues({
        LegacyFavoritesStore.favoritesKey: legacy([bookA]),
      });
      api.pages[0] = pageOf([bookA]);

      await signIn();

      expect(api.marked, isEmpty);
      expect(provider.migrationNotice, isNull);
      expect(provider.interests, hasLength(1));
    });

    test('interrompida sem rede, a fila fica para a próxima sessão', () async {
      SharedPreferences.setMockInitialValues({
        LegacyFavoritesStore.favoritesKey: legacy([bookA, bookB]),
      });
      api.writeFailureByBook[bookA.id] = const ApiException(ApiFailure.network);

      await signIn();

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList(LegacyFavoritesStore.favoritesKey),
        hasLength(2),
        reason: 'nada subiu, nada sai da fila',
      );
      expect(prefs.getBool(LegacyFavoritesStore.doneKey), isNull);
      expect(provider.migrationNotice, isNull);
    });

    test('id que a API não aceita sai da fila e não trava o resto', () async {
      const numeric = Book(
        id: '42',
        title: 'Livro de id numérico',
        author: 'Autor',
        imageUrl: '',
        rating: 0,
      );
      SharedPreferences.setMockInitialValues({
        LegacyFavoritesStore.favoritesKey: legacy([numeric, bookA]),
      });
      api.writeFailureByBook['42'] = const ApiException(
        ApiFailure.server,
        statusCode: 400,
      );

      await signIn();

      expect(api.marked, contains(bookA.id));
      expect(provider.migrationNotice, 1);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(LegacyFavoritesStore.doneKey), isTrue);
    });

    test('sem servidor confirmado a lista antiga não sobe', () async {
      SharedPreferences.setMockInitialValues({
        LegacyFavoritesStore.favoritesKey: legacy([bookA]),
      });
      api.mineFailure = const ApiException(ApiFailure.network);

      await signIn();

      expect(api.marked, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getStringList(LegacyFavoritesStore.favoritesKey),
        hasLength(1),
      );
    });
  });
}
