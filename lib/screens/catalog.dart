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

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  List<MapEntry<String, List<Book>>> _allCategories = [];
  List<MapEntry<String, List<Book>>> _displayedCategories = [];

  bool _isLoading = false;
  bool _initialLoad = true;

  @override
  void initState() {
    super.initState();
    _loadData(); // Nome alterado para refletir a nova lógica híbrida
    _scrollController.addListener(_onScroll);
  }

  /// Estratégia: Stale-while-revalidate
  /// 1. Mostra cache local imediatamente (se existir).
  /// 2. Busca dados novos na API em segundo plano.
  Future<void> _loadData() async {
    if (_isLoading) return;

    // --- 1. TENTATIVA LOCAL (Instantânea) ---
    try {
      final localCatalog = await _apiService.getCatalogLocal();

      if (localCatalog != null && localCatalog.isNotEmpty) {
        if (mounted) {
          setState(() {
            _allCategories = localCatalog.entries.toList();
            _updateDisplayedCategories();
            _initialLoad = false; // Remove o loading de tela cheia
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao ler cache local: $e');
      // Não fazemos nada, apenas seguimos para a API
    }

    // --- 2. TENTATIVA REMOTA (Atualização) ---
    // Só mostramos loading se a lista estiver vazia (sem cache)
    if (_allCategories.isEmpty) {
      setState(() => _isLoading = true);
    }

    try {
      final remoteCatalog = await _apiService.fetchAndSaveCatalog();

      if (mounted) {
        setState(() {
          _allCategories = remoteCatalog.entries.toList();
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
          // Se falhar a API mas já tivermos dados locais, não mostramos erro intrusivo,
          // apenas paramos o loading. Se estiver vazio, mostramos erro.
          if (_allCategories.isEmpty) {
            _initialLoad =
                false; // Para mostrar a mensagem de "vazio" ou erro no body
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro de conexão: Verifique sua internet.'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          } else {
            // Opcional: Avisar que está offline mas mostrando dados antigos
            // ScaffoldMessenger.of(context).showSnackBar(
            //   const SnackBar(content: Text('Modo Offline: Exibindo dados salvos.')),
            // );
          }
        });
      }
    }
  }

  /// Lógica centralizada para definir quantos itens aparecem na tela (Paginação)
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
    // No refresh manual, forçamos a busca na API
    try {
      final newCatalog = await _apiService.fetchAndSaveCatalog();
      if (mounted) {
        setState(() {
          _allCategories = newCatalog.entries.toList();
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
  Widget build(BuildContext context) {
    return Scaffold(
      // Se estiver carregando pela primeira vez E não tiver dados locais, mostra loading
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
                      // OTIMIZAÇÃO: Renderiza 500 pixels antes/depois da tela para evitar buracos brancos ao rolar rápido
                      cacheExtent: 500,
                      // OTIMIZAÇÃO: Mantém o estado dos carrosséis vivos (não reseta a posição horizontal ao rolar verticalmente)
                      addAutomaticKeepAlives: true,
                      physics: const AlwaysScrollableScrollPhysics(),

                      itemCount: _displayedCategories.length + 2,
                      itemBuilder: (context, index) {
                        // Espaço para o Header Customizado
                        if (index == 0) {
                          return const SizedBox(height: 140);
                        }

                        // Itens do Catálogo
                        if (index <= _displayedCategories.length) {
                          final category = _displayedCategories[index - 1];
                          // ValueKey é importante para performance na reciclagem de widgets
                          return BookCarousel(
                            key: ValueKey(category.key),
                            title: category.key,
                            books: category.value,
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

                        // Espaço final para não ficar colado na borda
                        return const SizedBox(height: 100);
                      },
                    ),
            ),
    );
  }
}
