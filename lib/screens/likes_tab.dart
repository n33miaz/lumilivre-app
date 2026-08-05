import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/widgets/book_card.dart';

class LikesTab extends StatelessWidget {
  const LikesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        final books = favoritesProvider.favoriteBooks;

        if (books.isEmpty) {
          // `grey.shade300` sobre `grey.shade600`: no tema escuro era o caso
          // clássico de cinza sobre cinza. Mesmo par dos outros estados vazios.
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: theme.hintColor.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.likesEmptyMessage,
                  style: TextStyle(color: theme.hintColor),
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
