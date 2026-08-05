import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:lumilivre/utils/app_motion.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription? _subscription;
  bool _isOffline = false;

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
  void dispose() {
    _subscription?.cancel();
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Faixa de aviso do sistema: `inverseSurface` é justamente a superfície
        // que contrasta com a tela nos dois temas — era um preto cravado, que no
        // tema escuro virava faixa preta sobre fundo quase preto.
        AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.page),
          height: _isOffline ? 32 : 0,
          color: scheme.inverseSurface,
          child: _isOffline
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      color: scheme.onInverseSurface,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Você está offline. Exibindo dados salvos.',
                      style: TextStyle(
                        color: scheme.onInverseSurface,
                        fontSize: 12,
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
        Expanded(child: widget.child),
      ],
    );
  }
}
