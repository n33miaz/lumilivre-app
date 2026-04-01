import 'package:flutter/material.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/book_carousel.dart';

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

    final Set<int> prominentlyDisplayedBookIds = {};
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
      debugPrint('Erro ao ler cache local: $e');
    }

    // --- TENTATIVA REMOTA ---
    if (_allCategories.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final remoteCatalog = await _apiService.fetchAndSaveCatalog();

      if (mounted) {
        setState(() {
          _allCategories = _processCatalog(remoteCatalog);
          _updateDisplayedCategories();
          _isLoading = false;
          _initialLoad = false;
        });
      }
    } catch (e) {
      debugPrint('Erro na UI ao buscar catálogo remoto: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (_allCategories.isEmpty) {
            _initialLoad = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro de conexão: Verifique sua internet.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Modo Offline: Exibindo dados salvos.'),
              ),
            );
          }
        });
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

  Future<void> _handleRefresh() async {
    // Refresh manual força a busca na API
    try {
      final newCatalog = await _apiService.fetchAndSaveCatalog();
      if (mounted) {
        setState(() {
          _allCategories = _processCatalog(newCatalog);
          _updateDisplayedCategories();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível atualizar o catálogo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
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
