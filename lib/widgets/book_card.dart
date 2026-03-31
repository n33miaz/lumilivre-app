import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/screens/book_details.dart';

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
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BookDetailsScreen(book: book),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 0.1);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              final tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                ),
              );
            },
          ),
        );
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
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
                                color: colorScheme.surfaceVariant.withOpacity(0.3),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: (context, url, error) => _buildPlaceholder(),
                              memCacheWidth: 420,
                            )
                          : _buildPlaceholder(),
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
                          color: Colors.black.withOpacity(0.6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                book.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                    height: isCompact ? 50 : 60, // Altura fixa para alinhar o autor embaixo
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          book.title,
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
                              color: Theme.of(context).hintColor.withOpacity(0.7),
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

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Image.asset(
        'assets/images/capa-padrao.png',
        fit: BoxFit.cover,
      ),
    );
  }
}
