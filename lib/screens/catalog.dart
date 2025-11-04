import 'package:flutter/material.dart';
import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/widgets/book_carousel.dart';
import 'package:lumilivre/widgets/header.dart';

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
    _fetchInitialData();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _fetchInitialData() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final catalogData = await _apiService.getCatalog();
      _allCategories = catalogData.entries.toList();
      _loadMoreCategories();
    } catch (e) {
      // Tratar erro
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _initialLoad = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _loadMoreCategories();
    }
  }

  void _loadMoreCategories() {
    if (_isLoading || _displayedCategories.length >= _allCategories.length)
      return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_initialLoad)
            const Center(child: CircularProgressIndicator())
          else if (_allCategories.isEmpty)
            const Center(child: Text('Nenhum livro encontrado no catálogo.'))
          else
            ListView.builder(
              controller: _scrollController,
              itemCount:
                  _displayedCategories.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SizedBox(height: 160);
                }
                if (index <= _displayedCategories.length) {
                  final category = _displayedCategories[index - 1];
                  return BookCarousel(
                    key: ValueKey(category.key),
                    title: category.key,
                    books: category.value,
                  );
                }
                if (_displayedCategories.length < _allCategories.length) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return const SizedBox(height: 100);
              },
            ),
          const CustomHeader(title: 'LumiLivre'),
        ],
      ),
    );
  }
}
