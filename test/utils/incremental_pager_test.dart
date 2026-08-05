import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/models/paged_result.dart';
import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/utils/incremental_pager.dart';

/// Testes do [IncrementalPager] — a peça que as três listas paginadas usam.
///
/// Os erros que ele existe para impedir eram todos invisíveis na tela: uma
/// rajada de requisições da mesma página, uma lista que se apagava ao falhar, e
/// um laço de tentativas que só aparecia no `logcat`.
void main() {
  PagedResult<String> pageOf(int page, {int size = 3, bool isLast = false}) =>
      PagedResult<String>(
        items: List<String>.generate(size, (i) => 'p$page-i$i'),
        page: page,
        isLast: isLast,
      );

  group('IncrementalPager', () {
    test('semente entra na lista sem consumir página', () {
      var calls = 0;
      final pager = IncrementalPager<String>(
        fetchPage: (page) async {
          calls++;
          return pageOf(page);
        },
        keyOf: (item) => item,
        seed: const ['a', 'b'],
      );

      expect(pager.items, ['a', 'b']);
      expect(calls, 0);
      expect(pager.hasMore, isTrue);
      // Nada sendo buscado: nenhum indicador de progresso no fim da lista.
      expect(pager.hasFooter, isFalse);
    });

    test(
      'não abre segunda requisição enquanto a primeira está em voo',
      () async {
        var calls = 0;
        final gate = Completer<void>();
        final pager = IncrementalPager<String>(
          fetchPage: (page) async {
            calls++;
            await gate.future;
            return pageOf(page);
          },
          keyOf: (item) => item,
        );

        // É o que o listener de rolagem faz: chama a cada quadro.
        final first = pager.loadMore();
        final second = pager.loadMore();
        final third = pager.loadMore();

        expect(calls, 1);
        expect(pager.isLoading, isTrue);
        expect(pager.canLoadMore, isFalse);

        gate.complete();
        await Future.wait([first, second, third]);

        expect(calls, 1);
        expect(pager.items, hasLength(3));
        expect(pager.isLoading, isFalse);
      },
    );

    test('avança as páginas e para no isLast que o servidor manda', () async {
      final requested = <int>[];
      final pager = IncrementalPager<String>(
        fetchPage: (page) async {
          requested.add(page);
          return pageOf(page, isLast: page == 1);
        },
        keyOf: (item) => item,
      );

      await pager.loadMore();
      await pager.loadMore();

      expect(requested, [0, 1]);
      expect(pager.items, hasLength(6));
      expect(pager.hasMore, isFalse);
      expect(pager.canLoadMore, isFalse);

      // Última página cheia não custa uma requisição vazia para descobrir o fim.
      await pager.loadMore();
      expect(requested, [0, 1]);
    });

    test('erro ao paginar preserva o que já está na lista', () async {
      final pager = IncrementalPager<String>(
        fetchPage: (page) async {
          if (page == 1) {
            throw const SocketException('sem rota para o host');
          }
          return pageOf(page);
        },
        keyOf: (item) => item,
      );

      await pager.loadMore();
      final aoVivo = List<String>.from(pager.items);
      expect(aoVivo, hasLength(3));

      await pager.loadMore();

      expect(pager.failed, isTrue);
      expect(pager.lastFailure, ApiFailure.network);
      expect(pager.items, aoVivo);
      expect(pager.hasFooter, isTrue);
    });

    test('não repete sozinho a página que falhou', () async {
      final attempts = <int>[];
      final pager = IncrementalPager<String>(
        fetchPage: (page) async {
          attempts.add(page);
          if (page == 1) {
            throw const SocketException('sem rota para o host');
          }
          return pageOf(page);
        },
        keyOf: (item) => item,
      );

      await pager.loadMore();
      await pager.loadMore();

      // O dedo continua no fim da lista e o listener continua chamando.
      await pager.loadMore();
      await pager.loadMore();

      expect(attempts, [0, 1]);
      expect(pager.canLoadMore, isFalse);
    });

    test('retry tenta a mesma página de novo e volta ao normal', () async {
      final attempts = <int>[];
      var falhaPendente = true;
      final pager = IncrementalPager<String>(
        fetchPage: (page) async {
          attempts.add(page);
          if (page == 1 && falhaPendente) {
            falhaPendente = false;
            throw const SocketException('sem rota para o host');
          }
          return pageOf(page, isLast: page == 1);
        },
        keyOf: (item) => item,
      );

      await pager.loadMore();
      await pager.loadMore();
      expect(pager.failed, isTrue);

      await pager.retry();

      expect(attempts, [0, 1, 1]);
      expect(pager.failed, isFalse);
      expect(pager.lastFailure, isNull);
      expect(pager.items, hasLength(6));
      expect(pager.hasMore, isFalse);
    });

    test('não repete item que já está na lista', () async {
      final pager = IncrementalPager<String>(
        fetchPage: (page) async => PagedResult<String>(
          items: const ['repetido', 'novo'],
          page: page,
          isLast: true,
        ),
        keyOf: (item) => item,
        seed: const ['repetido'],
      );

      await pager.loadMore();

      expect(pager.items, ['repetido', 'novo']);
    });

    test('reseed recomeça da primeira página', () async {
      final requested = <int>[];
      final pager = IncrementalPager<String>(
        fetchPage: (page) async {
          requested.add(page);
          return pageOf(page);
        },
        keyOf: (item) => item,
        seed: const ['antigo'],
      );

      await pager.loadMore();
      expect(requested, [0]);

      pager.reseed(const ['novo']);

      expect(pager.items, ['novo']);
      expect(pager.hasMore, isTrue);
      expect(pager.failed, isFalse);

      await pager.loadMore();
      expect(requested, [0, 0]);
    });

    test('erro síncrono do fetcher não trava o pager em carregando', () async {
      var calls = 0;
      final pager = IncrementalPager<String>(
        // Sem `async`: a exceção sai antes de qualquer `await`, que é o caso em
        // que o controle de "uma requisição em voo" pode ficar preso ligado.
        fetchPage: (page) {
          calls++;
          throw const SocketException('estourou antes de sair');
        },
        keyOf: (item) => item,
      );

      await pager.loadMore();

      expect(calls, 1);
      expect(pager.isLoading, isFalse);
      expect(pager.failed, isTrue);

      await pager.retry();
      expect(calls, 2);
    });
  });
}
