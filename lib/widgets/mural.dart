import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/app_content.dart';
import 'package:lumilivre/providers/auth.dart';
import 'package:lumilivre/providers/content_provider.dart';
import 'package:lumilivre/providers/guest_access.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/app_modal.dart';
import 'package:lumilivre/widgets/app_toast.dart';
import 'package:lumilivre/widgets/section_rule.dart';

/// Botão do mural no cabeçalho, com selo de publicação não vista.
///
/// O mural era a terceira aba da barra inferior, e como aba custava caro: era a
/// única que aparecia e sumia conforme a configuração da biblioteca, e cada
/// índice do navegador virava conta condicional. Como botão de cabeçalho — a
/// mesma construção do de tema, no canto que já estava vazio do outro lado — ele
/// ainda ganha o que aba nenhuma tem: dizer que há coisa nova sem ser aberto.
class MuralButton extends StatefulWidget {
  const MuralButton({super.key});

  /// Largura e altura do botão, iguais às do botão de tema (ícone de 20 com 8
  /// de folga de cada lado). O cabeçalho reserva esta medida quando a
  /// biblioteca desliga o mural, para o título continuar no centro.
  static const double diameter = 36;

  @override
  State<MuralButton> createState() => _MuralButtonState();
}

class _MuralButtonState extends State<MuralButton> {
  String? _requestedToken;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Quem pedia o feed era a tela da aba, ao ser montada. Sem aba, o selo de
    // "novo" só acenderia depois de alguém abrir o mural — que é justamente a
    // informação que o selo existe para dar antes. Então o botão pede o feed uma
    // vez por sessão, e o `ContentProvider` ignora a chamada repetida.
    final token = Provider.of<AuthProvider>(context).user?.token;
    if (!GuestAccess.of(context).canReadContents) return;
    if (token == null || token.isEmpty || token == _requestedToken) return;

    _requestedToken = token;
    final contents = Provider.of<ContentProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) contents.load(token);
    });
  }

  Future<void> _open() async {
    final contents = Provider.of<ContentProvider>(context, listen: false);

    await showAppDialog<void>(
      context: context,
      builder: (_) => const _MuralModal(),
    );

    // Marca ao fechar, e não ao abrir: o que chegou pelo pull-to-refresh com o
    // modal aberto também já passou pelos olhos de quem estava lendo.
    await contents.markSeen();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unseen = Provider.of<ContentProvider>(context).unseenCount;

    return MergeSemantics(
      child: Semantics(
        label: unseen > 0
            ? '${l10n.muralTitle}: ${l10n.muralUnseenCount(unseen)}'
            : l10n.muralTitle,
        child: Material(
          color: LumiLivreTheme.onBrand.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(50),
          child: InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: _open,
            child: Padding(
              padding: const EdgeInsets.all(8),
              // O número do selo fica fora da leitura de tela porque a frase
              // acima já o diz por extenso — senão o TalkBack fala "3" solto
              // depois de "Mural: 3 publicações novas".
              child: ExcludeSemantics(
                child: Badge(
                  isLabelVisible: unseen > 0,
                  // Selo com a cor de erro do esquema: é o tom que o Material
                  // reserva para "olhe isto", e o único que não some no roxo do
                  // cabeçalho. Acima de 9 o número não caberia no círculo.
                  label: Text(unseen > 9 ? '9+' : '$unseen'),
                  child: const Icon(
                    Icons.campaign_outlined,
                    size: 20,
                    color: LumiLivreTheme.onBrand,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// O mural dentro de um diálogo.
///
/// A lista é a mesma que existia na tela cheia; o que muda é a moldura, e por
/// isso ela vive num widget separado do botão.
class _MuralModal extends StatelessWidget {
  const _MuralModal();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: ConstrainedBox(
        // Modal, e não tela: com poucas publicações o diálogo encolhe até onde a
        // lista acaba, e nunca passa de três quartos da altura — a moldura por
        // fora é o que deixa claro que dá para fechar tocando ao lado.
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.75,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cabeçalho da ficha: a régua fica embaixo porque acima dela não há
            // o que separar — é o topo da própria superfície. Antes o título e
            // a lista se encostavam sem nenhuma linha entre os dois.
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
              child: SectionRule.below(
                child: Row(
                  children: [
                    Expanded(child: AppSheetTitle(l10n.muralTitle)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      // O rótulo de "fechar" já vem traduzido nos cinco idiomas
                      // com o próprio Material; não precisa de chave nossa.
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            const Flexible(child: _MuralList()),
          ],
        ),
      ),
    );
  }
}

class _MuralList extends StatefulWidget {
  const _MuralList();

  @override
  State<_MuralList> createState() => _MuralListState();
}

class _MuralListState extends State<_MuralList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isAuthenticated) return;

    final token = auth.user?.token;
    if (token == null || token.isEmpty) return;

    Provider.of<ContentProvider>(context, listen: false).load(token);
  }

  Future<void> _handleRefresh() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = auth.user?.token;
    if (!auth.isAuthenticated || token == null || token.isEmpty) return;

    await Provider.of<ContentProvider>(context, listen: false).refresh(token);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final access = GuestAccess.of(context);
    final provider = Provider.of<ContentProvider>(context);

    // O mural é segmentado por público: sem sessão não há o que carregar.
    if (!access.canReadContents) {
      return _message(context, l10n.muralLoginPrompt);
    }

    if (provider.isLoading && provider.items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Falha de rede sem cache: erro explícito com retry (erro ≠ mural vazio).
    if (provider.error != null && provider.items.isEmpty) {
      return _buildErrorState(context, l10n);
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: Theme.of(context).colorScheme.primary,
      child: provider.items.isEmpty
          ? _buildEmptyState(context, l10n)
          : ListView.builder(
              // O diálogo se ajusta à lista curta em vez de esticar até o teto,
              // e continua rolando quando ela é longa.
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
              itemCount: provider.items.length,
              itemBuilder: (context, index) {
                return _ContentCard(
                  content: provider.items[index],
                  onTap: () =>
                      _showDetail(context, l10n, provider.items[index]),
                );
              },
            ),
    );
  }

  Widget _message(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 40),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 15, color: Theme.of(context).hintColor),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_outlined,
            size: 64,
            color: Theme.of(context).hintColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.muralError,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.muralRetry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    // Continua sendo lista rolável mesmo vazia: é o que deixa o
    // pull-to-refresh existir quando não há nada para puxar.
    return ListView(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(32, 8, 32, 40),
      children: [
        Icon(
          Icons.campaign_outlined,
          size: 64,
          color: Theme.of(context).hintColor.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.muralEmpty,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  void _showDetail(
    BuildContext context,
    AppLocalizations l10n,
    AppContent content,
  ) {
    showAppSheet(
      context: context,
      builder: (ctx) => _ContentDetailSheet(content: content, l10n: l10n),
    );
  }
}

/// Mapeamentos de tipo compartilhados entre card e detalhe.
String _typeLabel(AppLocalizations l10n, AppContent content) {
  if (content.isAnnouncement) return l10n.muralTypeAnnouncement;
  if (content.isAttachment) return l10n.muralTypeAttachment;
  if (content.isWork) return l10n.muralTypeWork;
  return content.contentType;
}

/// Cor de identidade do tipo, já ajustada para se ler sobre a superfície.
///
/// As três cores cruas (roxo da marca, rosa da marca e o azul do catálogo) só
/// funcionavam no tema claro: no escuro o selo ficava roxo sobre grafite. O azul
/// vem da paleta de categorias em vez de um hex repetido aqui.
Color _typeColor(BuildContext context, AppContent content) {
  if (content.isAttachment) {
    return LumiLivreTheme.readableInk(
      context,
      LumiLivreTheme.genreCardColors[3],
    );
  }
  if (content.isWork) {
    return LumiLivreTheme.readableInk(context, LumiLivreTheme.label);
  }
  return LumiLivreTheme.readableInk(context, LumiLivreTheme.primary);
}

Future<void> _openUrl(
  BuildContext context,
  AppLocalizations l10n,
  String url,
) async {
  final toast = AppToast.of(context);
  final uri = Uri.tryParse(url);
  // Só abre http/https. URLs vêm de conteúdo autorado por admin/biblio;
  // esquemas como intent://, tel:, market: ou custom são bloqueados.
  final allowed = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  var opened = false;
  if (allowed) {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Sem handler para o tipo (PDF/browser): cai no aviso abaixo.
      opened = false;
    }
  }
  if (!opened) {
    // Antes o aviso repetia a URL inteira, que num toast estoura a linha e não
    // diz o que fazer. A frase agora explica que o aparelho não tem com que abrir.
    toast.error(l10n.linkOpenError);
  }
}

class _TypeBadge extends StatelessWidget {
  final AppContent content;

  const _TypeBadge({required this.content});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _typeColor(context, content);

    // Etiqueta retangular, e não pastilha: a caixa alta pequena já era a forma
    // certa, faltava o espaçamento entre letras que faz dela uma cota — e o
    // canto quase arredondado, que é o que sobrava do desenho de pastilha.
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: CotaLabel(_typeLabel(l10n, content), color: color),
    );
  }
}

class _ContentCard extends StatelessWidget {
  final AppContent content;
  final VoidCallback onTap;

  const _ContentCard({required this.content, required this.onTap});

  String? _snippet(AppLocalizations l10n) {
    if (content.isWork && content.authors != null) {
      return l10n.muralByAuthors(content.authors!);
    }
    return content.body;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final snippet = _snippet(l10n);

    // Cor, elevação e raio saíram daqui: são os do `cardTheme`.
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(LumiLivreTheme.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (content.coverUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: content.coverUrl!,
                    width: 56,
                    height: 78,
                    fit: BoxFit.cover,
                    memCacheWidth: 160,
                    placeholder: (context, url) => Container(
                      width: 56,
                      height: 78,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 56,
                      height: 78,
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 20,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _TypeBadge(content: content),
                        const Spacer(),
                        if (content.pinned)
                          Icon(
                            Icons.push_pin,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      content.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        height: 1.15,
                      ),
                    ),
                    if (snippet != null && snippet.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        snippet,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).hintColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContentDetailSheet extends StatelessWidget {
  final AppContent content;
  final AppLocalizations l10n;

  const _ContentDetailSheet({required this.content, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppSheetHandle(),
              Row(
                children: [
                  _TypeBadge(content: content),
                  const Spacer(),
                  if (content.pinned)
                    Icon(
                      Icons.push_pin,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              AppSheetTitle(content.title),
              const SizedBox(height: 16),
              ..._buildTypeBody(context),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildTypeBody(BuildContext context) {
    if (content.isWork) {
      return _buildWorkBody(context);
    }
    if (content.isAttachment) {
      return _buildAttachmentBody(context);
    }
    return _buildAnnouncementBody(context);
  }

  List<Widget> _buildAnnouncementBody(BuildContext context) {
    return [
      if (content.body != null)
        Text(content.body!, style: const TextStyle(fontSize: 15, height: 1.4)),
    ];
  }

  List<Widget> _buildAttachmentBody(BuildContext context) {
    return [
      if (content.body != null) ...[
        Text(content.body!, style: const TextStyle(fontSize: 15, height: 1.4)),
        const SizedBox(height: 20),
      ],
      if (content.fileUrl != null)
        _actionButton(
          context,
          icon: Icons.description_outlined,
          label: l10n.muralOpenDocument,
          url: content.fileUrl!,
        ),
    ];
  }

  List<Widget> _buildWorkBody(BuildContext context) {
    return [
      if (content.body != null) ...[
        Text(content.body!, style: const TextStyle(fontSize: 15, height: 1.4)),
        const SizedBox(height: 16),
      ],
      if (content.authors != null)
        _metadataRow(context, l10n.muralAuthorsLabel, content.authors!),
      if (content.advisors != null)
        _metadataRow(context, l10n.muralAdvisorsLabel, content.advisors!),
      if (content.completionYear != null)
        _metadataRow(context, l10n.muralYearLabel, content.completionYear!),
      if (content.completionSemester != null)
        _metadataRow(
          context,
          l10n.muralSemesterLabel,
          content.completionSemester!,
        ),
      const SizedBox(height: 20),
      if (content.fileUrl != null)
        _actionButton(
          context,
          icon: Icons.description_outlined,
          label: l10n.muralOpenDocument,
          url: content.fileUrl!,
        ),
      if (content.fileUrl != null && content.externalUrl != null)
        const SizedBox(height: 12),
      if (content.externalUrl != null)
        _actionButton(
          context,
          icon: Icons.open_in_new,
          label: l10n.muralExternalLink,
          url: content.externalUrl!,
        ),
    ];
  }

  Widget _metadataRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String url,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _openUrl(context, l10n, url),
        icon: Icon(icon, size: 20),
        label: Text(label),
      ),
    );
  }
}
