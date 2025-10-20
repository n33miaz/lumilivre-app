import 'package:flutter/material.dart';

import 'package:lumilivre_app/utils/constants.dart';
import 'package:lumilivre_app/widgets/header.dart';
import 'package:lumilivre_app/widgets/genre_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> searchCategories = [
      'Recomendações',
      'Mais Vistos',
      'Novidades',
      'Aventura',
      'Romance',
      'Educativos',
      'Suspense',
      'Biografia',
      'Ficção Científica',
      'História',
      'Autoajuda',
      'Fantasia',
      'Terror',
      'Poesia',
      'TCCs',
      'Manuais',
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // TODO: deixar o header por cima (boxshadow)
          const SliverAppBar(
            pinned: true,
            expandedHeight: 130.0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: CustomHeader(title: ''),
              titlePadding: EdgeInsets.zero,
              centerTitle: true,
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                'Navegue por todos',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // grid dos cards
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.8,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                return GenreCard(
                  title: searchCategories[index],
                  color:
                      LumiLivreTheme.genreCardColors[index %
                          LumiLivreTheme.genreCardColors.length],
                  imagePath: 'assets/images/mock.png',
                );
              }, childCount: searchCategories.length),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
