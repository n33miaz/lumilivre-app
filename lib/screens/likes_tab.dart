import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/services/api_error.dart';
import 'package:lumilivre/widgets/app_toast.dart';
import 'package:lumilivre/widgets/book_card.dart';

/// Os curtidos do leitor, vindos do servidor.
///
/// A aba antes desenhava a lista que morava no `SharedPreferences` — sempre
/// completa, sempre instantânea e sempre só daquele aparelho. Agora ela é uma
/// lista paginada de rede, então precisa das quatro caras que qualquer lista de
/// rede tem: carregando, falhou, vazia e cheia. A diferença entre "não curtiu
/// nada" e "não deu para buscar" é o que a grade de categoria já errava antes.
class LikesTab extends StatefulWidget {
  const LikesTab({super.key});

  @override
  State<LikesTab> createState() => _LikesTabState();
}

class _LikesTabState extends State<LikesTab> {
  /// Distância do fim da grade em que a próxima página é pedida — cerca de uma
  /// linha e meia de capas.
  static const double _prefetch = 360.0;

  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_controller.hasClients) {
      return;
    }
    final position = _controller.position;
    if (position.maxScrollExtent - position.pixels <= _prefetch) {
      context.read<FavoritesProvider>().loadMore();
    }
  }

  /// Conta uma única vez o que subiu do aparelho para a conta.
  ///
  /// O aviso é da migração, não da lista: quem curtiu antes de o interesse existir
  /// no servidor precisa saber por que estes livros apareceram — e que pode
  /// desfazer com um toque.
  void _announceMigration(FavoritesProvider favorites) {
    final migrated = favorites.migrationNotice;
    if (migrated == null) {
      return;
    }
    favorites.acknowledgeMigrationNotice();

    final l10n = AppLocalizations.of(context)!;
    final toast = AppToast.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        toast.info(l10n.interestMigratedNotice(migrated));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favorites, child) {
        _announceMigration(favorites);

        final interests = favorites.interests;

        if (interests.isEmpty) {
          if (favorites.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (favorites.failed) {
            return _LikesFailure(
              failure: favorites.lastFailure,
              onRetry: favorites.retry,
            );
          }
          return const _LikesEmpty();
        }

        return RefreshIndicator(
          onRefresh: favorites.refresh,
          child: GridView.builder(
            controller: _controller,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 24,
              childAspectRatio: 0.5,
            ),
            itemCount: interests.length + (favorites.hasFooter ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == interests.length) {
                // Falha na página seguinte não apaga as anteriores: o último slot
                // vira a nova tentativa.
                if (favorites.failed) {
                  return Center(
                    child: IconButton(
                      onPressed: favorites.retry,
                      icon: const Icon(Icons.refresh),
                      tooltip: AppLocalizations.of(context)!.retryAction,
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              }
              return BookCard(book: interests[index].book);
            },
          ),
        );
      },
    );
  }
}

class _LikesEmpty extends StatelessWidget {
  const _LikesEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
}

/// Nem a primeira página veio. Sem cache e sem rede, dizer "você ainda não
/// curtiu nenhum livro" seria afirmar o que não se sabe.
class _LikesFailure extends StatelessWidget {
  const _LikesFailure({required this.failure, required this.onRetry});

  final ApiFailure? failure;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    // Sessão vencida e falta de rede pedem coisas diferentes de quem lê, e a aba
    // só chega aqui com leitor identificado — para o convidado o perfil já mostra
    // o convite ao login no lugar da lista.
    final expired = failure == ApiFailure.unauthorized;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              expired ? Icons.lock_outline : Icons.wifi_off_outlined,
              size: 56,
              color: theme.hintColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              expired
                  ? l10n.sessionExpiredMessage
                  : l10n.connectionErrorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.hintColor),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retryAction),
            ),
          ],
        ),
      ),
    );
  }
}
