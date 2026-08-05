import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/app_toast.dart';
import 'package:lumilivre/widgets/book_carousel.dart';
import 'package:provider/provider.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with AutomaticKeepAliveClientMixin {
  // Mantém a ordem das categorias preservada enquanto o app estiver na memória
  static List<String>? _persistedCategoryOrder;

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<MapEntry<String, List<Book>>> _allCategories = [];
  List<MapEntry<String, List<Book>>> _displayedCategories = [];

  bool _isLoading = false;
  bool _initialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  List<MapEntry<String, List<Book>>> _processCatalog(
    Map<String, List<Book>> catalog,
  ) {
    // Define a ordem do catálogo apenas quando for a primeira vez
    if (_persistedCategoryOrder == null) {
      _persistedCategoryOrder = catalog.keys.toList()..shuffle();
    } else {
      // Caso a API traga categorias novas
      final existingKeys = _persistedCategoryOrder!.toSet();
      final newKeys =
          catalog.keys.where((k) => !existingKeys.contains(k)).toList()
            ..shuffle();
      _persistedCategoryOrder!.addAll(newKeys);
    }

    final Set<String> prominentlyDisplayedBookIds = {};
    final List<MapEntry<String, List<Book>>> processedCategories = [];

    // Monta a lista mantendo a ordem estática e balanceando a exibição dos livros
    for (final categoryKey in _persistedCategoryOrder!) {
      if (!catalog.containsKey(categoryKey)) continue;

      final books = List<Book>.from(catalog[categoryKey]!);

      // Ordena livros da categoria
      books.sort((a, b) {
        final aHasCover = a.imageUrl.isNotEmpty;
        final bHasCover = b.imageUrl.isNotEmpty;

        // Prioriza quem tem capa
        if (aHasCover && !bHasCover) return -1;
        if (!aHasCover && bHasCover) return 1;

        // Penaliza livros já mostrados no topo de categorias anteriores
        final aSeen = prominentlyDisplayedBookIds.contains(a.id);
        final bSeen = prominentlyDisplayedBookIds.contains(b.id);

        if (aSeen && !bSeen) return 1;
        if (!aSeen && bSeen) return -1;

        return b.rating.compareTo(a.rating);
      });

      // Marca os 5 primeiros livros dessa categoria como "destaque"
      // para não aparecerem repetidos no início das PRÓXIMAS categorias
      for (var book in books.take(5)) {
        prominentlyDisplayedBookIds.add(book.id);
      }

      processedCategories.add(MapEntry(categoryKey, books));
    }

    return processedCategories;
  }

  /// Stale-while-revalidate
  // 1. Mostra cache local imediatamente (se existir).
  // 2. Busca dados novos na API em segundo plano.
  Future<void> _loadData() async {
    if (_isLoading) return;

    // --- TENTATIVA LOCAL ---
    try {
      final localCatalog = await _apiService.getCatalogLocal();

      if (localCatalog != null && localCatalog.isNotEmpty) {
        if (mounted) {
          setState(() {
            _allCategories = _processCatalog(localCatalog);
            _updateDisplayedCategories();
            _initialLoad = false;
          });
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao ler cache local: $e');
    }

    // --- TENTATIVA REMOTA ---
    if (_allCategories.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final remoteCatalog = await _apiService.fetchAndSaveCatalog(
        token: _sessionToken(),
      );

      if (mounted) {
        setState(() {
          _allCategories = _processCatalog(remoteCatalog);
          _updateDisplayedCategories();
          _isLoading = false;
          _initialLoad = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro na UI ao buscar catálogo remoto: $e');

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final toast = AppToast.of(context);
        final hasCache = _allCategories.isNotEmpty;

        setState(() {
          _isLoading = false;
          if (!hasCache) {
            _initialLoad = false;
          }
        });

        // Sem cache é erro; com cache é só um aviso de que os dados são os
        // salvos. Antes os dois avisos eram disparados dentro do `setState`, o
        // que fazia o `ScaffoldMessenger` ser chamado durante a reconstrução.
        if (hasCache) {
          toast.info(l10n.offlineCachedDataMessage);
        } else {
          toast.error(l10n.connectionErrorMessage);
        }
      }
    }
  }

  /// Lógica de Paginação
  void _updateDisplayedCategories() {
    final nextEnd = 4.clamp(0, _allCategories.length);
    _displayedCategories = _allCategories.sublist(0, nextEnd);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreCategories();
    }
  }

  void _loadMoreCategories() {
    if (_isLoading || _displayedCategories.length >= _allCategories.length) {
      return;
    }

    setState(() {
      final nextEnd = (_displayedCategories.length + 4).clamp(
        0,
        _allCategories.length,
      );
      _displayedCategories = _allCategories.sublist(0, nextEnd);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Token da sessão real, ou `null` em modo convidado.
  ///
  /// O catálogo é rota pública: o token aqui só serve para a auditoria de acessos
  /// atribuir a visita ao leitor certo. Vem do `AuthProvider` porque é ele que
  /// conhece o estado de sessão depois do gate biométrico — o `CatalogApi` lia
  /// direto do armazenamento seguro e mandava credencial de uma sessão travada.
  String? _sessionToken() =>
      Provider.of<AuthProvider>(context, listen: false).sessionToken;

  Future<void> _handleRefresh() async {
    // Refresh manual força a busca na API
    try {
      final newCatalog = await _apiService.fetchAndSaveCatalog(
        token: _sessionToken(),
      );
      if (mounted) {
        setState(() {
          _allCategories = _processCatalog(newCatalog);
          _updateDisplayedCategories();
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        AppToast.of(context).error(l10n.catalogRefreshError);
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: _initialLoad && _displayedCategories.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: LumiLivreTheme.primary,
              child: _allCategories.isEmpty
                  ? ListView(
                      // ...
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      // `cacheExtent` está depreciado em favor de
                      // `scrollCacheExtent`, mas o substituto (e o tipo
                      // `ScrollCacheExtent`) só entrou no Flutter 3.43. O CI fixa
                      // 3.41.4, onde trocar não seria aviso: seria erro de
                      // compilação.
                      cacheExtent: 500,
                      addAutomaticKeepAlives: true,
                      physics: const AlwaysScrollableScrollPhysics(),

                      itemCount: _displayedCategories.length + 2,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const SizedBox(height: 130);
                        }

                        // Itens do Catálogo
                        if (index <= _displayedCategories.length) {
                          final category = _displayedCategories[index - 1];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 18),
                            child: BookCarousel(
                              key: ValueKey(category.key),
                              title: category.key,
                              books: category.value,
                            ),
                          );
                        }

                        // Loader de Paginação (final da lista)
                        if (_displayedCategories.length <
                            _allCategories.length) {
                          return const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        return const SizedBox(height: 100);
                      },
                    ),
            ),
    );
  }
}
