import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/models/paged_result.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/screens/category_books.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/app_motion.dart';
import 'package:lumilivre/utils/incremental_pager.dart';
import 'package:lumilivre/widgets/book_card.dart';
import 'package:provider/provider.dart';

class BookCarousel extends StatefulWidget {
  final String title;

  /// Livros que o catálogo já entregou para esta categoria.
  ///
  /// São no máximo 10 (`rn <= 10` em `findCatalogoMobile`) e podem vir do cache
  /// local, então esta é a primeira tela da esteira — não a lista do gênero.
  final List<Book> books;

  const BookCarousel({super.key, required this.title, required this.books});

  @override
  State<BookCarousel> createState() => _BookCarouselState();
}

class _BookCarouselState extends State<BookCarousel> {
  static const double _itemWidth = 150.0 + 16.0; // card + gap

  /// Distância do fim em que a próxima página é pedida — três cartões antes.
  ///
  /// O limiar é o que faz a busca acontecer "ao aproximar do fim" em vez de a
  /// cada pixel arrastado; quem garante que dois quadros seguidos não abram duas
  /// requisições da mesma página é o [IncrementalPager], que mantém uma só em
  /// voo. Um atraso por tempo em cima disso só empurraria a primeira requisição
  /// para frente: a quantidade de requisições é limitada pelo número de páginas,
  /// não pelo número de eventos de rolagem.
  static const double _prefetchThreshold = _itemWidth * 3;

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  late IncrementalPager<Book> _pager;

  @override
  void initState() {
    super.initState();
    _pager = _createPager();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(BookCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    // O catálogo revalida em segundo plano (SWR) e pode trocar a primeira tela da
    // esteira. Sem recomeçar, as páginas já buscadas continuariam empilhadas
    // sobre uma lista que a API não devolve mais.
    if (widget.title != oldWidget.title ||
        !listEquals(widget.books, oldWidget.books)) {
      if (widget.title != oldWidget.title) {
        _pager = _createPager();
      } else {
        _pager.reseed(widget.books);
      }
    }
  }

  IncrementalPager<Book> _createPager() => IncrementalPager<Book>(
    fetchPage: _fetchPage,
    keyOf: (book) => book.id,
    seed: widget.books,
  );

  /// Busca a página [page] do gênero.
  ///
  /// Começa na página 0 mesmo já tendo a semente na tela, de propósito: a semente
  /// vem de `/api/books/catalog`, ordenada por data de publicação, e as páginas
  /// vêm de `/api/books/genres/{genreName}` com ordenação própria. Retomar da
  /// página 1 assumiria que as duas rotas concordam sobre quais são os 10
  /// primeiros livros — e elas não concordam. A sobreposição é resolvida pela
  /// deduplicação por id do pager; pular livro, não teria como resolver.
  ///
  /// O token sai do `AuthProvider` a cada busca, e não de uma propriedade fixada
  /// no widget, para acompanhar quem entrou na conta com o catálogo já aberto.
  Future<PagedResult<Book>> _fetchPage(int page) {
    final token = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).sessionToken;

    return _apiService.getBooksByGenre(widget.title, page: page, token: token);
  }

  void _onScroll() {
    if (!_scrollController.hasClients || !_pager.canLoadMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.maxScrollExtent - position.pixels <= _prefetchThreshold) {
      _loadMore();
    }
  }

  void _loadMore() => _track(_pager.loadMore());

  void _retry() => _track(_pager.retry());

  void _track(Future<void> loading) {
    setState(() {});
    loading.then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
      // Uma página curta pode deixar o fim da esteira ainda dentro do limiar. Sem
      // reavaliar depois do layout, a busca só continuaria no próximo gesto — e o
      // usuário veria a esteira parar sem motivo.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _onScroll();
        }
      });
    });
  }

  void _navigateToCategory(BuildContext context) {
    Navigator.of(context).push(
      AppPageRoute<void>(
        context: context,
        builder: (_) => CategoryBooksScreen(categoryName: widget.title),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => _navigateToCategory(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 300, child: RepaintBoundary(child: _buildStrip())),
      ],
    );
  }

  Widget _buildStrip() {
    final books = _pager.items;

    if (books.isEmpty) {
      if (_pager.isLoading) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      if (_pager.failed) {
        return Center(child: _CarouselFooter(failed: true, onRetry: _retry));
      }
      return const SizedBox.shrink();
    }

    final footerSlots = _pager.hasFooter ? 1 : 0;

    return ListView.builder(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: books.length + footerSlots,
      // `cacheExtent` segue depreciado em favor de `scrollCacheExtent`, mas o
      // substituto (e o tipo `ScrollCacheExtent`) só existe a partir do Flutter
      // 3.43: o CI fixa 3.41.4, onde trocar viraria erro de compilação.
      cacheExtent: _itemWidth * 4,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        if (index == books.length) {
          return _CarouselFooter(failed: _pager.failed, onRetry: _retry);
        }

        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: BookCard(
            key: ValueKey(books[index].id),
            book: books[index],
            isCompact: true,
          ),
        );
      },
    );
  }
}

/// Último slot da esteira: carregando a próxima página, ou falhou.
///
/// Erro aqui não apaga a esteira — os livros já buscados continuam roláveis e o
/// slot final vira o convite a tentar de novo. É por isso também que o pager não
/// volta a pedir sozinho depois de falhar: o dedo continua no fim da lista, e o
/// listener repetiria a página que acabou de dar erro a cada quadro.
class _CarouselFooter extends StatelessWidget {
  const _CarouselFooter({required this.failed, required this.onRetry});

  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (!failed) {
      return const SizedBox(
        width: _BookCarouselState._itemWidth,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: _BookCarouselState._itemWidth,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              tooltip: l10n.retryAction,
            ),
            Text(
              l10n.loadMoreError,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
