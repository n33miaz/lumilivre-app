import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/widgets/book_card.dart';

class LikesTab extends StatelessWidget {
  const LikesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final books = favoritesProvider.favoriteBooks;

        if (books.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'Você ainda não curtiu nenhum livro.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 24,
            childAspectRatio: 0.5,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            return BookCard(book: books[index]);
          },
        );
      },
    );
  }
}
