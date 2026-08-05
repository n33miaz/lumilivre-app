import 'package:flutter/material.dart';
import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/screens/category_books.dart';
import 'package:lumilivre/utils/app_motion.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/genre_card.dart';

/// Uma categoria da grade: o gênero que a API entende, a arte e o rótulo.
///
/// [genre] e [label] existem separados porque o mesmo texto fazia dois papéis:
/// era o que aparecia no cartão **e** o que ia na rota
/// `/api/books/genres/{genero}`. O acervo é catalogado em pt-BR, então traduzir
/// o cartão traduziria a consulta junto e toda categoria voltaria vazia fora do
/// português. Agora [genre] é chave (fixa) e [label] é tela (traduzida).
class CategoryItem {
  final String genre;
  final String Function(AppLocalizations) label;
  final String imagePath;

  const CategoryItem({
    required this.genre,
    required this.label,
    required this.imagePath,
  });
}

const _allCategories = [
  CategoryItem(
    genre: 'TCCs',
    label: _thesisLabel,
    imagePath: 'assets/images/categories/TCCs.png',
  ),
  CategoryItem(
    genre: 'Aventura',
    label: _adventureLabel,
    imagePath: 'assets/images/categories/Aventura.png',
  ),
  CategoryItem(
    genre: 'Romance',
    label: _romanceLabel,
    imagePath: 'assets/images/categories/Romance.png',
  ),
  CategoryItem(
    genre: 'Educativo',
    label: _educationalLabel,
    imagePath: 'assets/images/categories/Educativo.png',
  ),
  CategoryItem(
    genre: 'Suspense',
    label: _thrillerLabel,
    imagePath: 'assets/images/categories/Suspense.png',
  ),
  CategoryItem(
    genre: 'Biografia',
    label: _biographyLabel,
    imagePath: 'assets/images/categories/Biografia.png',
  ),
  CategoryItem(
    genre: 'Ficção',
    label: _fictionLabel,
    imagePath: 'assets/images/categories/Ficcao.png',
  ),
  CategoryItem(
    genre: 'História',
    label: _historyLabel,
    imagePath: 'assets/images/categories/História.png',
  ),
  CategoryItem(
    genre: 'Autoajuda',
    label: _selfHelpLabel,
    imagePath: 'assets/images/categories/Autoajuda.png',
  ),
  CategoryItem(
    genre: 'Fantasia',
    label: _fantasyLabel,
    imagePath: 'assets/images/categories/Fantasia.png',
  ),
  CategoryItem(
    genre: 'Terror',
    label: _horrorLabel,
    imagePath: 'assets/images/categories/Terror.png',
  ),
  CategoryItem(
    genre: 'Poesia',
    label: _poetryLabel,
    imagePath: 'assets/images/categories/Poesia.png',
  ),
  CategoryItem(
    genre: 'Ciência e Tecnologia',
    label: _scienceTechnologyLabel,
    imagePath: 'assets/images/categories/Ciencia.png',
  ),
  CategoryItem(
    genre: 'Infantojuvenil',
    label: _childrenAndTeensLabel,
    imagePath: 'assets/images/categories/Infantojuvenil.jpg',
  ),
];

// Referências de função em nível superior porque `_allCategories` é `const`: um
// lambda não é constante e uma lista não-const recriaria a grade a cada quadro.
String _thesisLabel(AppLocalizations l10n) => l10n.genreThesis;
String _adventureLabel(AppLocalizations l10n) => l10n.genreAdventure;
String _romanceLabel(AppLocalizations l10n) => l10n.genreRomance;
String _educationalLabel(AppLocalizations l10n) => l10n.genreEducational;
String _thrillerLabel(AppLocalizations l10n) => l10n.genreThriller;
String _biographyLabel(AppLocalizations l10n) => l10n.genreBiography;
String _fictionLabel(AppLocalizations l10n) => l10n.genreFiction;
String _historyLabel(AppLocalizations l10n) => l10n.genreHistory;
String _selfHelpLabel(AppLocalizations l10n) => l10n.genreSelfHelp;
String _fantasyLabel(AppLocalizations l10n) => l10n.genreFantasy;
String _horrorLabel(AppLocalizations l10n) => l10n.genreHorror;
String _poetryLabel(AppLocalizations l10n) => l10n.genrePoetry;
String _scienceTechnologyLabel(AppLocalizations l10n) =>
    l10n.genreScienceTechnology;
String _childrenAndTeensLabel(AppLocalizations l10n) =>
    l10n.genreChildrenAndTeens;

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  void _navigateToCategory(BuildContext context, String genre, String title) {
    // A categoria subia a tela inteira de baixo enquanto o resto do app usava
    // outras três transições. Empilhar tela é sempre a mesma ação.
    Navigator.of(context).push(
      AppPageRoute<void>(
        context: context,
        builder: (_) => CategoryBooksScreen(genre: genre, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 140)),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text(
                l10n.browseAllTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
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
                final category = _allCategories[index];
                final title = category.label(l10n);

                return GenreCard(
                  title: title,
                  color:
                      LumiLivreTheme.genreCardColors[index %
                          LumiLivreTheme.genreCardColors.length],
                  imagePath: category.imagePath,
                  onTap: () =>
                      _navigateToCategory(context, category.genre, title),
                );
              }, childCount: _allCategories.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
