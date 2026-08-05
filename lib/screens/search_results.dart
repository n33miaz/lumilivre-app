import 'package:flutter/material.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/widgets/app_toast.dart';
import 'package:lumilivre/widgets/book_card.dart';
import 'package:provider/provider.dart';

class SearchResultsScreen extends StatefulWidget {
  final String query;

  const SearchResultsScreen({super.key, required this.query});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final ApiService _apiService = ApiService();
  final List<Book> _books = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _doSearch();
  }

  Future<void> _doSearch() async {
    // A busca é rota pública; o token identifica o acesso na auditoria e vem do
    // provider, nunca do armazenamento seguro (ver `CatalogApi`).
    final token = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).sessionToken;

    try {
      final results = await _apiService.searchBooks(widget.query, token: token);
      if (mounted) {
        setState(() {
          _books.addAll(results.items);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppToast.of(context).error(AppLocalizations.of(context)!.searchError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Resultados para "${widget.query}"'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _books.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.hintColor.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum livro encontrado.',
                    style: TextStyle(color: theme.hintColor),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.5,
              ),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                return BookCard(book: _books[index]);
              },
            ),
    );
  }
}
