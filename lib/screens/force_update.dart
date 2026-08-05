import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/models/app_version_info.dart';
import 'package:lumilivre/widgets/app_toast.dart';

/// Tela de bloqueio exibida quando a versão instalada não é mais
/// suportada. Não é dispensável: precede a autenticação e o usuário só sai
/// dela atualizando o app.
class ForceUpdateScreen extends StatelessWidget {
  final AppVersionInfo? info;

  const ForceUpdateScreen({super.key, this.info});

  Future<void> _launchStore(BuildContext context, String url) async {
    final toast = AppToast.of(context);
    final errorText = AppLocalizations.of(context)!.forceUpdateStoreError;
    // Só abre http/https (storeUrl vem da config de versão no banco).
    final uri = Uri.tryParse(url);
    var opened = false;
    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      try {
        opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        opened = false;
      }
    }
    // Numa tela sem saída, falha silenciosa deixaria o usuário travado sem pista.
    if (!opened) {
      toast.error(errorText);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final message = (info?.updateMessage?.trim().isNotEmpty ?? false)
        ? info!.updateMessage!.trim()
        : l10n.forceUpdateMessage;
    final storeUrl = info?.storeUrl;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // A marca aqui é tinta sobre a tela, não superfície: no tema
                  // escuro o roxo cravado deixava o logo quase invisível.
                  SvgPicture.asset(
                    'assets/icons/logo.svg',
                    height: 120,
                    semanticsLabel: l10n.logoSemanticLabel,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Icon(
                    Icons.system_update,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.forceUpdateTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: theme.hintColor),
                  ),
                  const SizedBox(height: 32),
                  if (storeUrl != null && storeUrl.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => _launchStore(context, storeUrl),
                      icon: const Icon(Icons.open_in_new),
                      label: Text(
                        l10n.forceUpdateButton,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
