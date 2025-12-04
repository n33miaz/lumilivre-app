import 'package:flutter/material.dart';

import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/genre_card.dart';
import 'package:lumilivre/screens/category_books.dart';

class CategoryItem {
  final String title;
  final String imagePath;

  CategoryItem({required this.title, required this.imagePath});
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  void _navigateToCategory(BuildContext context, String categoryName) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CategoryBooksScreen(categoryName: categoryName),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          final tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<CategoryItem> categories = [
      CategoryItem(
        title: 'TCCs',
        imagePath: 'assets/images/categories/TCCs.png',
      ),
      CategoryItem(
        title: 'Aventura',
        imagePath: 'assets/images/categories/Aventura.png',
      ),
      CategoryItem(
        title: 'Romance',
        imagePath: 'assets/images/categories/Romance.png',
      ),
      CategoryItem(
        title: 'Educativo',
        imagePath: 'assets/images/categories/Educativo.png',
      ),
      CategoryItem(
        title: 'Suspense',
        imagePath: 'assets/images/categories/Suspense.png',
      ),
      CategoryItem(
        title: 'Biografia',
        imagePath: 'assets/images/categories/Biografia.png',
      ),
      CategoryItem(
        title: 'Ficção',
        imagePath:
            'assets/images/categories/Ficcao.png',
      ),
      CategoryItem(
        title: 'História',
        imagePath: 'assets/images/categories/História.png',
      ),
      CategoryItem(
        title: 'Autoajuda',
        imagePath: 'assets/images/categories/Autoajuda.png',
      ),
      CategoryItem(
        title: 'Fantasia',
        imagePath: 'assets/images/categories/Fantasia.png',
      ),
      CategoryItem(
        title: 'Terror',
        imagePath: 'assets/images/categories/Terror.png',
      ),
      CategoryItem(
        title: 'Poesia',
        imagePath: 'assets/images/categories/Poesia.png',
      ),
      CategoryItem(
        title: 'Ciência e Tecnologia',
        imagePath:
            'assets/images/categories/Ciencia.png',
      ),
      CategoryItem(
        title: 'Infantojuvenil',
        imagePath:
            'assets/images/categories/Infantojuvenil.jpg',
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 140)),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Navegue por todos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                childAspectRatio: 1.6,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final category = categories[index];

                return GestureDetector(
                  onTap: () => _navigateToCategory(context, category.title),
                  child: GenreCard(
                    title: category.title,
                    color:
                        LumiLivreTheme.genreCardColors[index %
                            LumiLivreTheme.genreCardColors.length],
                    imagePath:
                        category.imagePath,
                  ),
                );
              }, childCount: categories.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
