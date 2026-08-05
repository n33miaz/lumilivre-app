import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';
import 'request_context.dart';

/// Gate biométrico da sessão.
///
/// O toggle de Configurações antes só gravava a preferência: `local_auth` nunca
/// era chamado e o auto-login não consultava nada. O usuário achava que tinha
/// trancado a sessão e não tinha trancado nada — o que é pior que não oferecer a
/// funcionalidade. Aqui a preferência só é gravada depois de uma autenticação
/// bem-sucedida, e a restauração da sessão passa por [confirmToUnlock].
///
/// Política: **falha fechado**. Sensor ausente, biometria descadastrada, erro de
/// plataforma ou cancelamento do usuário são todos tratados como "não
/// autenticado" — nunca como "deixa passar".
class BiometricAuth {
  BiometricAuth({LocalAuthentication? localAuth})
    : _localAuth = localAuth ?? LocalAuthentication();

  /// Mesma chave da versão decorativa do toggle: quem já tinha ligado não perde
  /// a preferência ao atualizar (só passa a valer de verdade).
  static const String preferenceKey = 'biometricsEnabled';

  final LocalAuthentication _localAuth;

  /// Aparelho com sensor **e** biometria cadastrada.
  ///
  /// `isDeviceSupported` sozinho também aceita aparelho com sensor mas sem
  /// digital/rosto cadastrado; nesse caso o toggle prometeria uma proteção que
  /// falharia em toda tentativa, então a lista de biometrias entra na conta.
  Future<bool> isSupported() async {
    // Na web (e em desktop) o plugin não está registrado: a chamada estouraria
    // em MissingPluginException e o toggle nem é mostrado nessas plataformas.
    if (kIsWeb) {
      return false;
    }
    try {
      if (!await _localAuth.isDeviceSupported()) {
        return false;
      }
      final enrolled = await _localAuth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } catch (e) {
      if (kDebugMode) debugPrint('BiometricAuth.isSupported falhou: $e');
      return false;
    }
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(preferenceKey) ?? false;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(preferenceKey, value);
  }

  /// Confirmação exigida para **ligar** o toggle.
  Future<bool> confirmToEnable() async {
    final messages = await _messages();
    return _authenticate(messages.biometricEnablePrompt);
  }

  /// Confirmação exigida antes de restaurar a sessão salva.
  Future<bool> confirmToUnlock() async {
    final messages = await _messages();
    return _authenticate(messages.biometricUnlockPrompt);
  }

  Future<bool> _authenticate(String reason) async {
    if (kIsWeb) {
      return false;
    }
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          // O prompt sobrevive ao app ir para segundo plano (é o que acontece
          // quando o sistema pede a digital): sem isto a autenticação seria
          // cancelada e a sessão cairia sem o usuário ter errado nada.
          stickyAuth: true,
          // Aceita o PIN/padrão do aparelho como alternativa. Sem essa saída,
          // quem apaga a digital cadastrada fica sem auto-login e sem entender
          // o motivo; o gate continua valendo, só muda o fator.
          biometricOnly: false,
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('BiometricAuth.authenticate falhou: $e');
      return false;
    }
  }

  /// Mensagem do prompt do sistema no idioma escolhido no app.
  ///
  /// O gate roda na inicialização, fora da árvore de widgets, então não há
  /// `BuildContext` para `AppLocalizations.of`: o idioma vem da mesma
  /// preferência que o `Accept-Language` das requisições já usa.
  Future<AppLocalizations> _messages() async {
    final tag = await RequestContext.currentLocaleTag();
    final parts = tag.split(RegExp('[-_]'));
    final locale = parts.length >= 2
        ? Locale(parts[0], parts[1])
        : Locale(parts.first);
    return AppLocalizations.delegate.isSupported(locale)
        ? lookupAppLocalizations(locale)
        : lookupAppLocalizations(const Locale('pt'));
  }
}
