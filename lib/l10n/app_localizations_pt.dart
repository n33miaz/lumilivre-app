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

  @override
  String get readerTerm => 'Leitor';

  @override
  String get filterRanking => 'Filtrar Ranking';

  @override
  String get courseLabel => 'Curso';

  @override
  String get moduleLabel => 'Módulo';

  @override
  String get shiftLabel => 'Turno';

  @override
  String get applyFilters => 'APLICAR FILTROS';

  @override
  String get clearFilters => 'Limpar Filtros';

  @override
  String get emptyRankingMessage => 'Nenhum leitor encontrado.';

  @override
  String get rankingLoginPrompt => 'Faça login para ver o ranking.';

  @override
  String get rankingUnavailable => 'Ranking indisponível para esta biblioteca.';
}
