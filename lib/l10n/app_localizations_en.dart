// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LumiLivre';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get languageSection => 'Language';

  @override
  String get securitySection => 'Security';

  @override
  String get accountSection => 'Account';

  @override
  String get themeLabel => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get themeDark => 'Dark';

  @override
  String get languagePortuguese => 'Portuguese (Brazil)';

  @override
  String get languageEnglish => 'English (US)';

  @override
  String get biometricAccess => 'Biometric access';

  @override
  String get biometricSubtitle => 'Sign in with fingerprint or face.';

  @override
  String get biometricUnavailable =>
      'Biometrics are not available on this device.';

  @override
  String get changePassword => 'Change password';

  @override
  String get logout => 'Sign out';

  @override
  String get guestSettingsPrompt => 'Sign in to access all settings';

  @override
  String get loginAction => 'Sign in';

  @override
  String get readerTerm => 'Reader';

  @override
  String get filterRanking => 'Filter Ranking';

  @override
  String get courseLabel => 'Course';

  @override
  String get moduleLabel => 'Module';

  @override
  String get shiftLabel => 'Shift';

  @override
  String get applyFilters => 'APPLY FILTERS';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get emptyRankingMessage => 'No readers found.';

  @override
  String get rankingLoginPrompt => 'Sign in to see the ranking.';

  @override
  String get rankingUnavailable => 'Ranking is not available for this library.';
}
