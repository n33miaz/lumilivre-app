import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/book_interest.dart';
import '../models/paged_result.dart';
import '../services/api_error.dart';
import '../services/interest_api.dart';
import '../services/legacy_favorites_store.dart';
import '../utils/incremental_pager.dart';
import 'auth.dart';

/// Os livros que o leitor quer ler — no servidor, não no aparelho.
///
/// Antes esta lista era um `List<String>` de JSON no `SharedPreferences`: trocar
/// de celular perdia tudo e a biblioteca nunca sabia o que os alunos querem. Agora
/// a fonte da verdade é `GET /api/books/interests/mine`, e o que sobra no
/// aparelho é **cache de leitura** — o app abre offline mostrando o que o servidor
/// disse por último, e nada mais.
///
/// Três decisões moram aqui, e é delas que depende o app não mentir:
///
/// - **Pintura otimista com convergência.** O coração muda no toque, porque
///   esperar a rede para reagir a um toque em botão de curtir é o tipo de latência
///   que faz o usuário tocar de novo. Mas o estado final é sempre o corpo que o
///   servidor devolveu, e falha desfaz a pintura ([toggle]). O que o servidor não
///   aceitou não fica na tela.
/// - **Sem fila de escrita offline.** Marcar é escrita, e fila de escrita pede
///   resolução de conflito de verdade: dois aparelhos, o mesmo livro, marcar aqui
///   e desmarcar lá, sem carimbo de tempo por operação para decidir quem ganha.
///   Ressuscitar uma curtida que a pessoa tirou é pior que não aceitar a curtida
///   agora. Sem rede, a escrita falha, o coração volta e a tela avisa.
/// - **A lista antiga do aparelho sobe uma vez.** Ver [_migrateLegacy].
class FavoritesProvider with ChangeNotifier {
  FavoritesProvider({InterestApi? api, LegacyFavoritesStore? legacyStore})
    : _api = api ?? InterestApi(),
      _legacy = legacyStore ?? LegacyFavoritesStore();

  final InterestApi _api;
  final LegacyFavoritesStore _legacy;

  /// Token da sessão, recebido do `AuthProvider` em [syncWithAuth]. É `null` para
  /// convidado e para sessão travada pela biometria.
  String? _token;

  /// Conta a que a lista em memória pertence — matrícula, ou o id do usuário
  /// quando não houver. Serve para o cache não atravessar contas no mesmo
  /// aparelho e para descartar resposta de uma sessão que já terminou.
  String? _accountKey;

  final List<BookInterest> _items = <BookInterest>[];
  final Set<String> _ids = <String>{};

  /// Livros com escrita em voo: o segundo toque no mesmo coração não abre outra
  /// requisição.
  final Set<String> _pending = <String>{};

  /// Desmarcados nesta sessão. Uma página que já estava em trânsito quando o
  /// leitor desmarcou não pode ressuscitar o cartão.
  final Set<String> _dismissed = <String>{};

  late final UnmodifiableListView<BookInterest> _view =
      UnmodifiableListView<BookInterest>(_items);

  IncrementalPager<BookInterest>? _pager;

  /// A lista na tela veio do cache e ainda não foi confirmada pelo servidor.
  bool _fromCache = false;

  /// Quantos curtidos locais acabaram de subir, para a tela contar ao leitor.
  int? _migrationNotice;

  /// Interesses conhecidos, do mais recente para o mais antigo (a ordem que a
  /// API devolve).
  List<BookInterest> get interests => _view;

  bool isFavorite(String bookId) => _ids.contains(bookId);

  /// Há escrita em voo para este livro — o coração fica sem reagir a novos toques
  /// em vez de enfileirar idas à rede.
  bool isPending(String bookId) => _pending.contains(bookId);

  /// Existe leitor identificado. Convidado não tem interesse: interesse sem dono
  /// não é dado.
  bool get hasSession => _token != null && _token!.isNotEmpty;

  bool get isLoading => _pager?.isLoading ?? false;
  bool get hasMore => _pager?.hasMore ?? false;
  bool get failed => _pager?.failed ?? false;
  ApiFailure? get lastFailure => _pager?.lastFailure;
  bool get hasFooter => _pager?.hasFooter ?? false;

  /// A lista mostrada é a do cache, sem confirmação do servidor nesta abertura.
  bool get isStale => _fromCache;

  int? get migrationNotice => _migrationNotice;

  /// A tela já contou ao leitor o que subiu. Não notifica: quem chama está
  /// justamente terminando de desenhar.
  void acknowledgeMigrationNotice() => _migrationNotice = null;

  /// Acompanha a sessão.
  ///
  /// Sem leitor identificado, a lista e o cache saem do aparelho — a curtida é de
  /// quem entrou, e não do celular. Token novo da mesma conta (o que a troca de
  /// senha emite) **não** invalida nada: a lista continua sendo a mesma, só a
  /// credencial mudou.
  void syncWithAuth(AuthProvider auth) {
    final token = auth.sessionToken;
    final account = auth.isAuthenticated
        ? (auth.user?.readerRegistrationNumber?.isNotEmpty ?? false
              ? auth.user!.readerRegistrationNumber!
              : auth.user?.id)
        : null;

    if (token == null || token.isEmpty || account == null || account.isEmpty) {
      if (_token != null || _items.isNotEmpty || _pager != null) {
        _token = null;
        _accountKey = null;
        unawaited(_forget());
      }
      return;
    }

    if (_accountKey == account) {
      _token = token;
      return;
    }

    _token = token;
    _accountKey = account;
    _reset();
    _pager = _newPager();
    // Fora do build: `syncWithAuth` roda dentro do `update` do provider, e
    // notificar listener no meio da construção da árvore é erro de framework.
    scheduleMicrotask(_startSession);
  }

  /// Cache primeiro (para o app abrir offline com algo verdadeiro), servidor
  /// depois (porque a lista é dele), e só então o que sobrou do aparelho.
  Future<void> _startSession() async {
    final account = _accountKey;
    if (account == null) {
      return;
    }

    final cached = await _api.cachedMine(account);
    if (_accountKey != account) {
      return;
    }
    if (cached.isNotEmpty && _items.isEmpty) {
      _absorb(cached);
      _fromCache = true;
      notifyListeners();
    }

    await loadMore();
    if (_accountKey != account || _fromCache || failed) {
      // Sem confirmação do servidor não há como saber o que já está lá: subir a
      // lista antiga agora arriscaria contar como migrado o que a conta já tinha
      // — e, sem rede, nem sairia do lugar.
      return;
    }
    await _migrateLegacy();
  }

  IncrementalPager<BookInterest> _newPager() => IncrementalPager<BookInterest>(
    fetchPage: _fetchPage,
    keyOf: (interest) => interest.book.id,
  );

  /// Busca uma página e a absorve na lista da tela.
  ///
  /// A página 0 **substitui** o que estava na tela: ela é a resposta autoritativa
  /// mais recente, e o que estava era cache ou uma lista de antes de o leitor
  /// mexer em outro aparelho. Só ela vai para o cache — guardar todas as páginas
  /// faria o cache parecer o acervo curtido inteiro sem ser.
  Future<PagedResult<BookInterest>> _fetchPage(int page) async {
    final token = _token;
    final account = _accountKey;
    if (token == null || token.isEmpty || account == null) {
      throw const ApiException(ApiFailure.unauthorized);
    }

    final result = await _api.getMine(page: page, token: token);
    if (_accountKey != account) {
      return result;
    }

    if (page == 0) {
      _items.clear();
      _ids.clear();
      _dismissed.clear();
      _fromCache = false;
      unawaited(_api.cacheMine(account, result.items));
    }
    _absorb(result.items);
    return result;
  }

  /// Próxima página da lista de curtidos.
  Future<void> loadMore() async {
    final pager = _pager;
    if (pager == null || !pager.canLoadMore) {
      return;
    }
    await pager.loadMore();
    notifyListeners();
  }

  /// Nova tentativa depois de uma falha de paginação.
  Future<void> retry() async {
    final pager = _pager;
    if (pager == null) {
      return;
    }
    await pager.retry();
    notifyListeners();
  }

  /// Recomeça da página 0 (pull-to-refresh).
  Future<void> refresh() async {
    if (!hasSession) {
      return;
    }
    _pager = _newPager();
    await loadMore();
  }

  /// Garante que "este livro está marcado?" seja resposta do servidor, e não da
  /// primeira página só.
  ///
  /// `interests/mine` é a **única** fonte dessa informação: nem o card do catálogo
  /// nem a ficha do livro trazem o estado do interesse. Sem isto, o coração de um
  /// livro curtido que caiu na segunda página apareceria vazio — estado falso, na
  /// direção menos visível. Quem chama é a ficha do livro, e o teto de páginas
  /// impede que uma lista imprevisível vire uma rajada de requisições.
  Future<void> ensureLoaded() async {
    const maxPages = 20;
    var pages = 0;

    while (hasSession && !failed && hasMore && pages++ < maxPages) {
      final pager = _pager!;
      // Devolve a mesma `Future` quando já há página em voo, então esperar aqui
      // não dispara requisição nova.
      await pager.loadMore();
      notifyListeners();
    }
  }

  /// Marca ou desmarca o interesse pelo [book].
  ///
  /// Devolve `null` quando o servidor aceitou, ou o motivo da recusa — a tela
  /// escolhe a frase e decide se convida ao login ou abre a troca de senha. O
  /// coração é pintado antes da resposta e **desfeito** quando ela não vem:
  /// [ApiFailure.passwordChangeRequired] não é falta de sessão e nunca desloga.
  Future<ApiFailure?> toggle(Book book) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      return ApiFailure.unauthorized;
    }
    if (_pending.contains(book.id)) {
      return null;
    }

    final wasMarked = _ids.contains(book.id);
    final previousIndex = _items.indexWhere((item) => item.book.id == book.id);
    final previous = previousIndex >= 0 ? _items[previousIndex] : null;

    _pending.add(book.id);
    if (wasMarked) {
      _remove(book.id);
    } else {
      _insert(BookInterest(book: book, markedAt: DateTime.now()));
    }
    notifyListeners();

    try {
      final state = wasMarked
          ? await _api.unmark(book.id, token: token)
          : await _api.mark(book.id, token: token);

      // O estado final é o do corpo da resposta, não o que a tela pintou.
      if (state.interested) {
        _insert(BookInterest(book: book, markedAt: state.markedAt));
      } else {
        _remove(book.id);
      }
      unawaited(_saveCache());
      return null;
    } catch (error) {
      if (wasMarked) {
        _restore(previous ?? BookInterest(book: book), previousIndex);
      } else {
        _remove(book.id);
      }
      return ApiException.fromError(error).failure;
    } finally {
      _pending.remove(book.id);
      notifyListeners();
    }
  }

  /// Sobe uma única vez a lista de curtidos que ficou no `SharedPreferences`.
  ///
  /// A escolha, entre descartar em silêncio e mandar tudo no primeiro login, foi
  /// **subir como mesclagem**, com três limites:
  ///
  /// - **Uma vez.** A chave antiga é a fila de trabalho: cada livro que sobe sai
  ///   dela, e ela só é marcada como lida quando esvazia. Interrupção (sem rede,
  ///   senha inicial pendente, balde de requisições cheio) retoma na sessão
  ///   seguinte, sem duplicar — marcar é idempotente na API.
  /// - **Só o que o servidor ainda não tem.** O que já veio em `interests/mine`
  ///   sai da fila sem requisição: a conta já sabe.
  /// - **Avisado.** A lista local não tem dono (o aparelho pode ter sido de outra
  ///   pessoa), então a tela conta quantos livros entraram na conta. Migrar
  ///   calado é o que transformaria um palpite nosso em fato para o leitor;
  ///   contado, um toque desfaz.
  Future<void> _migrateLegacy() async {
    if (await _legacy.isDone()) {
      return;
    }

    final token = _token;
    final account = _accountKey;
    if (token == null || account == null) {
      return;
    }

    final backlog = await _legacy.pending();
    if (backlog.isEmpty) {
      await _legacy.finish();
      return;
    }

    var migrated = 0;
    for (final book in backlog) {
      if (_token != token || _accountKey != account) {
        return;
      }
      if (_ids.contains(book.id)) {
        await _legacy.drop(book.id);
        continue;
      }

      try {
        final state = await _api.mark(book.id, token: token);
        if (state.interested) {
          _insert(BookInterest(book: book, markedAt: state.markedAt));
          migrated++;
        }
        await _legacy.drop(book.id);
      } catch (error) {
        final failure = ApiException.fromError(error);
        // 404 (livro que saiu do acervo) e 400 (id numérico das versões em que o
        // livro não tinha UUID) nunca vão subir: saem da fila para não travá-la.
        if (failure.failure == ApiFailure.notFound ||
            failure.statusCode == 400) {
          await _legacy.drop(book.id);
          continue;
        }
        break;
      }
    }

    if ((await _legacy.pending()).isEmpty) {
      await _legacy.finish();
    }
    if (migrated > 0) {
      _migrationNotice = migrated;
      await _saveCache();
      notifyListeners();
    }
  }

  Future<void> _saveCache() async {
    final account = _accountKey;
    if (account == null) {
      return;
    }
    await _api.cacheMine(
      account,
      _items.take(InterestApi.minePageSize).toList(growable: false),
    );
  }

  /// Acrescenta o que ainda não está na lista, respeitando o que o leitor acabou
  /// de desmarcar.
  void _absorb(Iterable<BookInterest> incoming) {
    for (final item in incoming) {
      final id = item.book.id;
      if (id.isEmpty || _dismissed.contains(id) || !_ids.add(id)) {
        continue;
      }
      _items.add(item);
    }
  }

  void _insert(BookInterest entry) {
    final id = entry.book.id;
    _dismissed.remove(id);
    _items.removeWhere((item) => item.book.id == id);
    _items.insert(0, entry);
    _ids.add(id);
  }

  void _remove(String bookId) {
    _items.removeWhere((item) => item.book.id == bookId);
    _ids.remove(bookId);
    _dismissed.add(bookId);
  }

  /// Devolve o cartão ao lugar em que estava quando o servidor recusa a remoção.
  void _restore(BookInterest entry, int index) {
    final id = entry.book.id;
    _dismissed.remove(id);
    if (!_ids.add(id)) {
      return;
    }
    _items.insert(index >= 0 && index <= _items.length ? index : 0, entry);
  }

  void _reset() {
    _items.clear();
    _ids.clear();
    _pending.clear();
    _dismissed.clear();
    _pager = null;
    _fromCache = false;
    _migrationNotice = null;
  }

  /// Logout (ou troca de usuário): esquece a lista aqui e no disco.
  Future<void> _forget() async {
    _reset();
    notifyListeners();
    await _api.clearCache();
  }
}
