import 'package:flutter/material.dart';

import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/genre_card.dart';
import 'package:lumilivre/screens/category_books.dart';

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
    final List<String> searchCategories = [
      'TCCs',
      'Aventura',
      'Romance',
      'Educativo',
      'Suspense',
      'Biografia',
      'Ficção',
      'História',
      'Autoajuda',
      'Fantasia',
      'Terror',
      'Poesia',
      'Ciência e Tecnologia',
      'Infantojuvenil',
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
                final category = searchCategories[index];
                return GestureDetector(
                  onTap: () => _navigateToCategory(context, category),
                  child: GenreCard(
                    title: category,
                    color:
                        LumiLivreTheme.genreCardColors[index %
                            LumiLivreTheme.genreCardColors.length],
                    imagePath: 'assets/images/mock.png',
                  ),
                );
              }, childCount: searchCategories.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
