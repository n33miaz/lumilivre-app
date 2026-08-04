import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/app_version_info.dart';
import '../services/api.dart';

/// Resultado do gate de atualização.
enum AppUpdateStatus {
  /// App atualizado o suficiente; nada a fazer.
  ok,

  /// Existe uma versão mais nova, mas o uso continua permitido.
  updateAvailable,

  /// Uso bloqueado: exige atualização antes de prosseguir.
  blocked,
}

/// Verifica, na inicialização, se a versão instalada ainda é suportada.
///
/// Política **fail-open**: qualquer erro de rede/timeout resulta em
/// [AppUpdateStatus.ok] para não bloquear o usuário offline (mesma tolerância
/// do `OfflineBanner`). Na web o gate é um no-op.
class AppUpdateProvider with ChangeNotifier {
  AppUpdateProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  AppUpdateStatus _status = AppUpdateStatus.ok;
  bool _checked = false;
  AppVersionInfo? _info;
  int _currentBuild = 0;

  AppUpdateStatus get status => _status;
  bool get checked => _checked;
  bool get isBlocked => _status == AppUpdateStatus.blocked;
  bool get updateAvailable => _status == AppUpdateStatus.updateAvailable;
  AppVersionInfo? get info => _info;
  int get currentBuild => _currentBuild;

  Future<void> check() async {
    // Na web não há loja/APK para atualizar: gate desativado.
    if (kIsWeb) {
      _status = AppUpdateStatus.ok;
      _checked = true;
      notifyListeners();
      return;
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _currentBuild = int.tryParse(packageInfo.buildNumber) ?? 0;

      final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
      final info = await _apiService.getAppVersion(platform: platform);
      _info = info;

      if (info.forceUpdate || _currentBuild < info.minSupportedBuild) {
        _status = AppUpdateStatus.blocked;
      } else if (_currentBuild < info.latestBuild) {
        _status = AppUpdateStatus.updateAvailable;
      } else {
        _status = AppUpdateStatus.ok;
      }
    } catch (e) {
      // Fail-open: nunca bloqueia por falha de rede/timeout.
      if (kDebugMode) debugPrint('AppUpdateProvider.check falhou: $e');
      _status = AppUpdateStatus.ok;
    } finally {
      _checked = true;
      notifyListeners();
    }
  }
}
