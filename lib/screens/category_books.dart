import 'package:flutter/material.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/book_card.dart';

class CategoryBooksScreen extends StatefulWidget {
  final String categoryName;

  const CategoryBooksScreen({super.key, required this.categoryName});

  @override
  State<CategoryBooksScreen> createState() => _CategoryBooksScreenState();
}

class _CategoryBooksScreenState extends State<CategoryBooksScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();

  final List<Book> _books = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchBooks();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading) {
        _fetchBooks();
      }
    });
  }

  Future<void> _fetchBooks() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final newBooks = await _apiService.getBooksByGenre(
        widget.categoryName,
        page: _currentPage,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        if (newBooks.isEmpty) {
          _hasMore = false;
        } else {
          _books.addAll(newBooks);
          _currentPage++;
        }
      });
    } catch (e) {
      debugPrint('Erro ao buscar livros: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMore = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar livros. Verifique a conexão.'),
          ),
        );
      }
    }
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
    // Initial loading
    if (_books.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state
    if (_books.isEmpty && !_hasMore) {
      return _buildEmptyState();
    }

    return _buildBookGrid();
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
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.5,
      ),
      itemCount: _books.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _books.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return BookCard(book: _books[index]);
      },
    );
  }
}
