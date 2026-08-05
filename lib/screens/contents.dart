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

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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

    await Provider.of<ContentProvider>(
      context,
      listen: false,
    ).refresh(token);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final l10n = AppLocalizations.of(context)!;
    final access = GuestAccess.of(context);
    final provider = Provider.of<ContentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          l10n.muralTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(context, l10n, access, provider),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    GuestAccess access,
    ContentProvider provider,
  ) {
    // O mural é segmentado por público: sem sessão não há o que carregar.
    if (!access.canReadContents) {
      return Center(child: Text(l10n.muralLoginPrompt));
    }

    if (provider.isLoading && provider.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Falha de rede sem cache: erro explícito com retry (erro ≠ mural vazio).
    if (provider.error != null && provider.items.isEmpty) {
      return _buildErrorState(context, l10n);
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: LumiLivreTheme.primary,
      child: provider.items.isEmpty
          ? _buildEmptyState(context, l10n)
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
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

  Widget _buildErrorState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).hintColor,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _handleRefresh,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.muralRetry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        Icon(
          Icons.campaign_outlined,
          size: 64,
          color: Theme.of(context).hintColor.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            l10n.muralEmpty,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showDetail(
    BuildContext context,
    AppLocalizations l10n,
    AppContent content,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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

Color _typeColor(AppContent content) {
  if (content.isAttachment) return const Color(0xFF1E3264);
  if (content.isWork) return LumiLivreTheme.label;
  return LumiLivreTheme.primary;
}

Future<void> _openUrl(
  BuildContext context,
  AppLocalizations l10n,
  String url,
) async {
  final messenger = ScaffoldMessenger.of(context);
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
    messenger.showSnackBar(
      SnackBar(content: Text('${l10n.muralOpenDocument}: $url')),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final AppContent content;

  const _TypeBadge({required this.content});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _typeColor(content);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _typeLabel(l10n, content).toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Theme.of(context).cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
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
                            color: LumiLivreTheme.primary,
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _TypeBadge(content: content),
                  const Spacer(),
                  if (content.pinned)
                    Icon(
                      Icons.push_pin,
                      size: 18,
                      color: LumiLivreTheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
        Text(
          content.body!,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
    ];
  }

  List<Widget> _buildAttachmentBody(BuildContext context) {
    return [
      if (content.body != null) ...[
        Text(
          content.body!,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
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
        Text(
          content.body!,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
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
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
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
