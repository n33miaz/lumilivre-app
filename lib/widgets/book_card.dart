import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/screens/book_details.dart';
import 'package:lumilivre/utils/app_motion.dart';
import 'package:lumilivre/utils/constants.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final double width;
  final bool isCompact;

  const BookCard({
    super.key,
    required this.book,
    this.width = 150,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    bool temImagemValida =
        book.imageUrl.isNotEmpty &&
        !book.imageUrl.contains('via.placeholder.com');

    final colorScheme = Theme.of(context).colorScheme;
    final infoPadding = isCompact
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 8);

    final titleSize = isCompact ? 12.0 : 13.0;
    final authorSize = isCompact ? 10.0 : 11.0;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          AppPageRoute<void>(
            context: context,
            builder: (_) => BookDetailsScreen(book: book),
          ),
        );
      },
      child: Container(
        width: width,
        // Filete no lugar da sombra, como em toda carta do app. Vem em
        // `foregroundDecoration` porque a borda de `decoration` é pintada
        // **antes** do filho, e aqui o filho é a capa sangrando até a margem —
        // ela cobriria a linha.
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LumiLivreTheme.radiusCard),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(LumiLivreTheme.radiusCard),
          child: Container(
            color: Theme.of(context).cardColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Capa do Livro + Rating
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 2 / 3,
                      child: temImagemValida
                          ? CachedNetworkImage(
                              imageUrl: book.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.3),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildPlaceholder(colorScheme),
                              memCacheWidth: 420,
                            )
                          : _buildPlaceholder(colorScheme),
                    ),

                    // Rating na Direita Fixo
                    Positioned(
                      top: 8,
                      right: 8,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          // Véu sobre a capa: `scrim` é o preto do tema, e a
                          // pastilha fica igual nos dois temas porque o que está
                          // atrás dela é a imagem, não a superfície.
                          color: colorScheme.scrim.withValues(alpha: 0.6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: LumiLivreTheme.rating,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                book.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: LumiLivreTheme.onBrand,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Informações do Livro
                Padding(
                  padding: infoPadding,
                  child: SizedBox(
                    height: isCompact
                        ? 50
                        : 60, // Altura fixa para alinhar o autor embaixo
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          book.title.trim().isNotEmpty
                              ? '${book.title.trim()[0].toUpperCase()}${book.title.trim().substring(1)}'
                              : '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleSize,
                            height: 1.1,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: authorSize + 2,
                              color: Theme.of(
                                context,
                              ).hintColor.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                book.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: authorSize,
                                  color: Theme.of(context).hintColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Image.asset('assets/images/capa-padrao.png', fit: BoxFit.cover),
    );
  }
}
