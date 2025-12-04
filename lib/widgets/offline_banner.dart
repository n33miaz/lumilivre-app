import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

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
      // Em caso de erro na verificação, assumimos que tem internet para não bloquear
      debugPrint('Erro ao verificar conectividade: $e');
    }
  }

  // CORREÇÃO AQUI: Aceita ConnectivityResult (singular) em vez de List
  void _updateStatus(dynamic result) {
    // Tratamento híbrido para garantir compatibilidade
    bool isOffline = false;

    if (result is List) {
      // Caso atualize a lib no futuro
      isOffline = result.contains(ConnectivityResult.none);
    } else if (result is ConnectivityResult) {
      // Versão atual (5.0.2)
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
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _isOffline ? 32 : 0,
          color: Colors.black87,
          child: _isOffline
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Você está offline. Exibindo dados salvos.',
                      style: TextStyle(color: Colors.white, fontSize: 12),
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
