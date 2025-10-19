import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:lumilivre_app/providers/theme.dart';
import 'package:lumilivre_app/utils/constants.dart';
import 'package:lumilivre_app/utils/mock-data.dart';
import 'package:lumilivre_app/widgets/book_carousel.dart';
import 'package:lumilivre_app/widgets/category_selector.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  String _selectedCategory = 'Principal';

  final List<String> _categories = [
    'Principal',
    'Gêneros',
    "PDF's, TCC's e Comunicados",
  ];

  Widget _buildCarousels() {
    switch (_selectedCategory) {
      case 'Gêneros':
        return Column(
          children: [
            BookCarousel(title: 'Aventura', books: mockBooks.reversed.toList()),
            BookCarousel(title: 'Romance', books: mockBooks),
            BookCarousel(
              title: 'Educativos',
              books: mockBooks.reversed.toList(),
            ),
            BookCarousel(title: 'Suspense', books: mockBooks),
            BookCarousel(
              title: 'Biografia',
              books: mockBooks.reversed.toList(),
            ),
            BookCarousel(title: 'Ficção Científica', books: mockBooks),
          ],
        );
      case "PDF's, TCC's e Comunicados":
        return Column(
          children: [
            BookCarousel(title: 'TCCs em Destaque', books: mockBooks),
            BookCarousel(
              title: 'Manuais e Apostilas',
              books: mockBooks.reversed.toList(),
            ),
            BookCarousel(title: 'Comunicados da Biblioteca', books: mockBooks),
          ],
        );
      case 'Principal':
      default:
        return Column(
          children: [
            BookCarousel(title: 'Recomendações', books: mockBooks),
            BookCarousel(
              title: 'Os mais vistos',
              books: mockBooks.reversed.toList(),
            ),
            BookCarousel(title: 'Novidades', books: mockBooks),
            BookCarousel(
              title: 'Adicionados Recentemente',
              books: mockBooks.reversed.toList(),
            ),
            BookCarousel(title: 'Clássicos da Literatura', books: mockBooks),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 170), // espaço começo dos carrosséis
                // seletor de categorias
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
                  child: _buildCarousels(),
                ),

                // TODO: adicionar um botão que redireciona o usuário para a página de pesquisa
                const SizedBox(height: 100), // espaço final dos carrosséis
              ],
            ),
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
