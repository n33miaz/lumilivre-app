import 'package:flutter/material.dart';

import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/services/api.dart';
import 'package:lumilivre/widgets/book_carousel.dart';
import 'package:lumilivre/widgets/category_selector.dart';
import 'package:lumilivre/widgets/header.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService _apiService = ApiService();
  Future<Map<String, List<Book>>>? _catalogFuture;

  String _selectedCategory = 'Principal';
  final List<String> _categories = [
    'Principal',
    'Gêneros',
    "PDF's, TCC's e Comunicados",
  ];

  @override
  void initState() {
    super.initState();
    _catalogFuture = _apiService.getCatalog();
  }

  Widget _buildCarousels(Map<String, List<Book>> catalogData) {
    // os mesmos carrosséis em todas as categorias, por enquanto

    final carousels = catalogData.entries.map((entry) {
      return BookCarousel(title: entry.key, books: entry.value);
    }).toList();

    return Column(children: carousels);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<Map<String, List<Book>>>(
            future: _catalogFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro ao carregar catálogo: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Nenhum livro encontrado no catálogo.'),
                );
              }

              final catalogData = snapshot.data!;

              // seletor de categorias
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 220),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: CategorySelector(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _buildCarousels(catalogData),
                    ),

                    // TODO: adicionar um botão que redireciona o usuário para a página de pesquisa
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
          const CustomHeader(title: 'LumiLivre'),
        ],
      ),
    );
  }
}
