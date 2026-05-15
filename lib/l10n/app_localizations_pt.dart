// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'LumiLivre';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearanceSection => 'Aparência';

  @override
  String get languageSection => 'Idioma';

  @override
  String get securitySection => 'Segurança';

  @override
  String get accountSection => 'Conta';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Escuro';

  @override
  String get languagePortuguese => 'Português (Brasil)';

  @override
  String get languageEnglish => 'English (US)';

  @override
  String get biometricAccess => 'Acesso com biometria';

  @override
  String get biometricSubtitle => 'Entrar com digital ou rosto.';

  @override
  String get biometricUnavailable =>
      'Biometria não disponível neste dispositivo.';

  @override
  String get changePassword => 'Mudar senha';

  @override
  String get logout => 'Sair da conta';

  @override
  String get guestSettingsPrompt =>
      'Faça login para acessar todas as configurações';

  @override
  String get loginAction => 'Entrar';
}
