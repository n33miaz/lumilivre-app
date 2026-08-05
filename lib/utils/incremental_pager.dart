import 'dart:async';
import 'dart:collection';

import '../models/paged_result.dart';
import '../services/api_error.dart';

/// Busca a página [page] da lista.
typedef PageFetcher<T> = Future<PagedResult<T>> Function(int page);

/// Identidade do item, para o pager não repetir o que já está na tela.
typedef ItemKey<T> = Object Function(T item);

/// Lista que cresce por página, com **uma** requisição em voo por vez.
///
/// Existe porque três telas paginavam à mão com o mesmo trio de campos
/// (`_isLoading`, `_hasMore`, `_currentPage`) e cada uma errava algo diferente:
/// a grade de categoria desligava a paginação para sempre no primeiro erro *e*
/// caía no estado vazio ("Nenhum livro encontrado") quando a falha acontecia na
/// primeira página, apagando a diferença entre "não tem livro" e "não deu para
/// buscar".
///
/// O que o pager garante, e é o que cada tela errava sozinha:
///
/// - **Uma requisição por vez.** `loadMore()` chamado durante um carregamento
///   devolve a mesma `Future` em vez de abrir outra requisição. É isso que
///   impede o listener de rolagem — que dispara a cada quadro — de virar uma
///   rajada de pedidos da mesma página.
/// - **Erro não apaga lista.** A falha marca [failed] e preserva [items]. Quem
///   já rolou cinco páginas não volta para zero por causa da sexta.
/// - **Erro não vira laço.** Depois de falhar, o pager para de aceitar
///   `loadMore()` automático: enquanto o dedo continua arrastando no fim da
///   lista, o listener seguiria pedindo a mesma página que acabou de falhar.
///   Retomar é decisão de quem está na tela, por [retry].
/// - **Fim de lista vem do servidor** ([PagedResult.isLast]), não de "a página
///   veio vazia".
class IncrementalPager<T> {
  IncrementalPager({
    required PageFetcher<T> fetchPage,
    required ItemKey<T> keyOf,
    List<T> seed = const [],
    int firstPage = 0,
  }) : _fetchPage = fetchPage,
       _keyOf = keyOf,
       _firstPage = firstPage,
       _nextPage = firstPage {
    _view = UnmodifiableListView<T>(_items);
    _absorb(seed);
  }

  final PageFetcher<T> _fetchPage;
  final ItemKey<T> _keyOf;
  final int _firstPage;

  final List<T> _items = <T>[];
  final Set<Object> _keys = <Object>{};
  late final UnmodifiableListView<T> _view;

  int _nextPage;
  Future<void>? _inFlight;
  bool _hasMore = true;
  bool _failed = false;
  ApiFailure? _lastFailure;

  /// Itens já carregados, na ordem em que entraram.
  List<T> get items => _view;

  bool get isEmpty => _items.isEmpty;

  /// Há uma requisição de página em voo.
  bool get isLoading => _inFlight != null;

  /// O servidor ainda não disse que a lista terminou.
  bool get hasMore => _hasMore;

  /// A última tentativa falhou e ninguém pediu para tentar de novo.
  bool get failed => _failed;

  /// Por que falhou, na taxonomia de [ApiFailure] — a tela responde diferente
  /// para falta de rede e para sessão vencida.
  ApiFailure? get lastFailure => _lastFailure;

  /// Vale pedir a próxima página agora. É o que o listener de rolagem consulta.
  bool get canLoadMore => _hasMore && !_failed && _inFlight == null;

  /// A lista tem algo a dizer no último slot: está buscando, ou falhou.
  ///
  /// Não inclui "ainda há páginas": haver próxima página sem estar buscando nada
  /// deixaria um indicador de progresso permanente no fim de toda lista.
  bool get hasFooter => _inFlight != null || _failed;

  /// Pede a próxima página.
  ///
  /// Sempre devolve uma `Future` que completa sem erro: a falha fica em [failed]
  /// e [lastFailure], porque quem chama é um listener de rolagem — um erro
  /// propagado ali não tem ninguém para tratá-lo e derruba o quadro.
  Future<void> loadMore() {
    final pending = _inFlight;
    if (pending != null) {
      return pending;
    }
    if (!_hasMore || _failed) {
      return Future<void>.value();
    }

    // O `Completer` é registrado antes de a busca começar. Atribuir a `Future`
    // devolvida por `_load()` seria tarde: se `_fetchPage` estourar de forma
    // síncrona, o `whenComplete` limparia `_inFlight` antes de ele ser escrito e
    // o pager travaria "carregando" para sempre.
    final completer = Completer<void>();
    _inFlight = completer.future;
    _load(_nextPage).whenComplete(() {
      _inFlight = null;
      completer.complete();
    });
    return completer.future;
  }

  /// Limpa o estado de erro e tenta a mesma página de novo.
  Future<void> retry() {
    _failed = false;
    _lastFailure = null;
    return loadMore();
  }

  /// Recomeça a lista a partir de [seed].
  ///
  /// É o que o catálogo faz quando a revalidação em segundo plano (SWR) traz uma
  /// primeira página nova: as páginas que já estavam na tela vieram da lista
  /// antiga e podem não existir mais.
  void reseed(List<T> seed) {
    _items.clear();
    _keys.clear();
    _nextPage = _firstPage;
    _hasMore = true;
    _failed = false;
    _lastFailure = null;
    _absorb(seed);
  }

  Future<void> _load(int page) async {
    try {
      final result = await _fetchPage(page);
      _absorb(result.items);
      _hasMore = !result.isLast;
      _nextPage = page + 1;
      _failed = false;
      _lastFailure = null;
    } catch (error) {
      _failed = true;
      _lastFailure = ApiException.fromError(error).failure;
    }
  }

  /// Acrescenta só o que ainda não está na lista.
  ///
  /// A deduplicação não é preciosismo: a primeira página da categoria vem do
  /// cache do catálogo, que é uma resposta de outra rota, com outra ordenação.
  /// Sem chave, o mesmo livro apareceria duas vezes na esteira.
  void _absorb(Iterable<T> incoming) {
    for (final item in incoming) {
      if (_keys.add(_keyOf(item))) {
        _items.add(item);
      }
    }
  }
}
