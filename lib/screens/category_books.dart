import 'package:flutter/material.dart';
import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/models/paged_result.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/utils/incremental_pager.dart';
import 'package:lumilivre/widgets/app_toast.dart';
import 'package:lumilivre/widgets/book_card.dart';
import 'package:provider/provider.dart';

class CategoryBooksScreen extends StatefulWidget {
  final String categoryName;

  const CategoryBooksScreen({super.key, required this.categoryName});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  late final IncrementalPager<Book> _pager = IncrementalPager<Book>(
    fetchPage: _fetchPage,
    keyOf: (book) => book.id,
  );

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  Future<PagedResult<Book>> _fetchPage(int page) {
    final token = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).sessionToken;

    return _apiService.getBooksByGenre(
      widget.categoryName,
      page: page,
      token: token,
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_pager.canLoadMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels <= 200) {
      _loadMore();
    }
  }

  void _loadMore() => _track(_pager.loadMore());

  void _retry() => _track(_pager.retry());

  /// Redesenha, e avisa uma vez por falha.
  ///
  /// A tela antes desligava a paginação para sempre no primeiro erro (`_hasMore =
  /// false`) e, quando a falha era na primeira página, caía no estado vazio
  /// "Nenhum livro encontrado" — dizendo que a categoria não tem livro quando o
  /// que houve foi falta de rede.
  void _track(Future<void> loading) {
    setState(() {});
    loading.then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      if (_pager.failed && _pager.items.isNotEmpty) {
        AppToast.of(context).error(AppLocalizations.of(context)!.loadMoreError);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onScroll();
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_pager.isEmpty) {
      if (_pager.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      if (_pager.failed) {
        return _buildFailureState();
      }
      return _buildEmptyState();
    }

    return _buildBookGrid();
  }

  /// Falha na primeira página. Antes isto se disfarçava de "categoria vazia".
  Widget _buildFailureState() {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_outlined,
              size: 56,
              color: theme.hintColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.bookListLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryAction),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: LumiLivreTheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                size: 48,
                color: LumiLivreTheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhum livro encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ainda não há livros cadastrados em "${widget.categoryName}".\nVolte em breve para novas adições!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              label: const Text('EXPLORAR OUTROS'),
              style: FilledButton.styleFrom(
                backgroundColor: LumiLivreTheme.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookGrid() {
    final books = _pager.items;
    final l10n = AppLocalizations.of(context)!;

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.5,
      ),
      itemCount: books.length + (_pager.hasFooter ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == books.length) {
          // Erro na página seguinte mantém a grade: o último slot vira o botão de
          // tentar de novo, e não o vazio.
          if (_pager.failed) {
            return Center(
              child: IconButton(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                tooltip: l10n.retryAction,
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        }
        return BookCard(book: books[index]);
      },
    );
  }
}
