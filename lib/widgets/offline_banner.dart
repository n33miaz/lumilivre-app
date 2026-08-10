import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';

import 'package:lumilivre/l10n/app_localizations.dart';
import 'package:lumilivre/services/api_health.dart';
import 'package:lumilivre/utils/app_motion.dart';
import 'package:lumilivre/widgets/app_toast.dart';

/// Faixa de estado do sistema: o que está errado agora e por quanto tempo.
///
/// Ela nasceu cobrindo **um** problema — o aparelho sem rede — e por isso o caso
/// que de fato acontece passava calado: a API roda em instância que hiberna, e
/// com a rede do celular perfeita o app simplesmente parava de carregar sem
/// dizer nada. Aqui as duas causas viram mensagens diferentes, porque a saída
/// também é diferente: sem rede quem resolve é a pessoa, servidor dormindo
/// resolve-se sozinho e o que ela precisa é saber disso e ver o tempo andar.
///
/// A explicação longa é passageira (um toast, uma vez por episódio) e o que fica
/// é esta faixa de 32 px — a mesma altura, a mesma superfície e a mesma
/// tipografia do aviso de offline que o app já tinha.
class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription? _subscription;
  bool _isOffline = false;

  ApiHealth? _health;
  ApiHealthStatus _lastStatus = ApiHealthStatus.unknown;

  /// Relógio da espera. Existe só enquanto o servidor está subindo: a faixa
  /// precisa mostrar o tempo andando, senão a espera de três minutos é lida como
  /// travamento — que foi exatamente o que aconteceu.
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    // Escuta mudanças na conexão
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      _updateStatus(result);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final health = Provider.of<ApiHealth>(context);
    _health = health;
    _reactTo(health.status);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateStatus(result);
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao verificar conectividade: $e');
    }
  }

  void _updateStatus(dynamic result) {
    bool isOffline = false;

    if (result is List) {
      isOffline = result.contains(ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      isOffline = result == ConnectivityResult.none;
    }

    if (mounted && _isOffline != isOffline) {
      setState(() {
        _isOffline = isOffline;
      });
    }
  }

  /// Reage à mudança de saúde da API: liga/desliga o relógio e dá a explicação
  /// longa uma única vez por episódio.
  void _reactTo(ApiHealthStatus status) {
    if (status == _lastStatus) {
      return;
    }
    final previous = _lastStatus;
    _lastStatus = status;

    if (status == ApiHealthStatus.waking) {
      _startTicker();
      _explain((l10n) => l10n.apiHealthWakingToast);
      return;
    }

    _stopTicker();
    if (previous == ApiHealthStatus.waking &&
        status == ApiHealthStatus.reachable) {
      _explain((l10n) => l10n.apiHealthRestoredToast);
    }
  }

  /// A explicação grande sai por [AppToast] — o mesmo canal de todo aviso
  /// transitório do app — e depois do frame: mostrar um aviso no meio do
  /// `build` é montar `SnackBar` durante a construção da árvore.
  ///
  /// Fica calada quando o aparelho está sem rede: nesse caso a causa é outra, a
  /// faixa já diz qual, e falar de servidor confundiria quem está no elevador.
  void _explain(String Function(AppLocalizations l10n) message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isOffline) {
        return;
      }
      final l10n = AppLocalizations.of(context);
      if (l10n == null) {
        return;
      }
      AppToast.of(context).info(message(l10n));
    });
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  /// `1:07`. Sem `intl` de propósito: são dígitos e um dois-pontos, iguais nos
  /// cinco idiomas, e a frase em volta é que vem traduzida.
  static String _formatElapsed(Duration elapsed) {
    final seconds = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${elapsed.inMinutes}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final health = _health;

    // Precedência: sem rede no aparelho ganha do servidor calado. Com o rádio
    // desligado toda chamada falha, e culpar o servidor seria mandar a pessoa
    // esperar por algo que só o aparelho dela resolve.
    final apiNotice = _isOffline || health == null
        ? null
        : switch (health.status) {
            ApiHealthStatus.waking => _Notice(
              icon: null,
              label: l10n.apiHealthWakingBanner(
                _formatElapsed(health.silentFor),
              ),
              onTap: null,
            ),
            ApiHealthStatus.unreachable => _Notice(
              icon: Icons.cloud_off,
              label: l10n.apiHealthUnreachableBanner,
              onTap: health.retryNow,
            ),
            _ => null,
          };

    final notice =
        apiNotice ??
        (_isOffline
            ? _Notice(
                icon: Icons.wifi_off,
                label: l10n.offlineBannerMessage,
                onTap: null,
              )
            : null);

    return Column(
      children: [
        // Faixa de aviso do sistema: `inverseSurface` é justamente a superfície
        // que contrasta com a tela nos dois temas — era um preto cravado, que no
        // tema escuro virava faixa preta sobre fundo quase preto.
        AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.page),
          height: notice != null ? 32 : 0,
          color: scheme.inverseSurface,
          child: notice == null
              ? const SizedBox.shrink()
              : _buildNotice(notice, scheme),
        ),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildNotice(_Notice notice, ColorScheme scheme) {
    final ink = scheme.onInverseSurface;

    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (notice.icon != null)
          Icon(notice.icon, color: ink, size: 16)
        else
          // Indicador de carregamento no lugar do ícone: é o que diferencia
          // "estamos esperando alguém" de "deu erro e acabou".
          SizedBox(
            height: 12,
            width: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: ink),
          ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            notice.label,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: ink, fontSize: 12),
          ),
        ),
      ],
    );

    if (notice.onTap == null) {
      return row;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: notice.onTap,
      child: row,
    );
  }
}

/// O conteúdo da faixa, já resolvido: um ícone (ou o indicador de espera), uma
/// frase e, quando cabe, uma ação.
@immutable
class _Notice {
  const _Notice({required this.icon, required this.label, required this.onTap});

  /// `null` significa "mostre o indicador de carregamento no lugar".
  final IconData? icon;
  final String label;
  final VoidCallback? onTap;
}
