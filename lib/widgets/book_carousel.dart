import 'package:flutter/material.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/screens/category_books.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/widgets/book_card.dart';

class BookCarousel extends StatefulWidget {
  final String title;

  /// Livros iniciais vindos do cache do catálogo (página 0 já resolvida).
  final List<Book> books;

  const BookCarousel({super.key, required this.title, required this.books});

  @override
  State<BookCarousel> createState() => _BookCarouselState();
}

class _BookCarouselState extends State<BookCarousel> {
  static const double _itemWidth = 150.0 + 16.0; // card + gap
  static const double _prefetchThreshold =
      _itemWidth * 3; // busca 3 cards antes do fim

  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  late List<Book> _books;
  int _nextPage = 1; // página 0 já veio no widget.books (seed do catálogo)
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _books = List<Book>.from(widget.books);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final distanceToEnd =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;

    if (distanceToEnd <= _prefetchThreshold && !_isLoading && _hasMore) {
      _fetchMore();
    }
  }

  Future<void> _fetchMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final newBooks = await _apiService.getBooksByGenre(
        widget.title,
        page: _nextPage,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (newBooks.isEmpty) {
          _hasMore = false;
        } else {
          // Evita duplicatas por id
          final existingIds = _books.map((b) => b.id).toSet();
          final unique = newBooks.where((b) => !existingIds.contains(b.id));
          _books.addAll(unique);
          _nextPage++;
        }
      });
    } catch (e) {
      debugPrint('BookCarousel: erro ao buscar mais livros — $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToCategory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
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
        SizedBox(
          height: 300,
          child: RepaintBoundary(
            child: _books.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _books.isEmpty
                ? const SizedBox.shrink()
                : ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    // +1 para o loader no final quando ainda há mais páginas
                    itemCount: _books.length + (_hasMore ? 1 : 0),
                    cacheExtent: _itemWidth * 4,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      // Último slot: loader de paginação
                      if (index == _books.length) {
                        return SizedBox(
                          width: _itemWidth,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }

                      final book = _books[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: BookCard(
                          key: ValueKey(book.id),
                          book: book,
                          isCompact: true,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
