import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lumilivre_app/models/book.dart';
import 'package:lumilivre_app/providers/theme.dart';
import 'package:lumilivre_app/services/api.dart';
import 'package:lumilivre_app/utils/constants.dart';
import 'package:lumilivre_app/widgets/book_carousel.dart';
import 'package:lumilivre_app/widgets/category_selector.dart';

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
          _buildHeader(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      height: 160,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: LumiLivreTheme.label.withOpacity(0.8),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () => themeProvider.toggleTheme(),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          themeProvider.isDarkMode
                              ? 'assets/icons/sun.svg'
                              : 'assets/icons/moon.svg',
                          height: 24,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'LumiLivre',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          Positioned(
            top: 90,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              // TODO: usar svg, deixar icone do lado direito com bg mais escuro, ajustar altura da label e bordar no modo escuro
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Digite algum livro ou autor',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
