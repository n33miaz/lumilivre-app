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

  @override
  String get muralTitle => 'Board';

  @override
  String get muralEmpty => 'Nothing posted here yet.';

  @override
  String get muralError => 'Couldn\'t load the board. Check your connection.';

  @override
  String get muralRetry => 'Try again';

  @override
  String get muralLoginPrompt => 'Sign in to see the board.';

  @override
  String get muralTypeAnnouncement => 'Announcement';

  @override
  String get muralTypeAttachment => 'Attachment';

  @override
  String get muralTypeWork => 'Work';

  @override
  String get muralOpenDocument => 'Open document';

  @override
  String get muralExternalLink => 'External link';

  @override
  String muralByAuthors(String authors) {
    return 'by $authors';
  }

  @override
  String get muralAuthorsLabel => 'Author(s)';

  @override
  String get muralAdvisorsLabel => 'Advisor(s)';

  @override
  String get muralYearLabel => 'Year';

  @override
  String get muralSemesterLabel => 'Semester';

  @override
  String get forceUpdateTitle => 'Update the app';

  @override
  String get forceUpdateMessage =>
      'A required new version is available. Please update to keep using LumiLivre.';

  @override
  String get forceUpdateButton => 'Update now';

  @override
  String get forceUpdateStoreError => 'Couldn\'t open the app store.';

  @override
  String get tourSkip => 'Skip';

  @override
  String get tourNext => 'Next';

  @override
  String get tourFinish => 'Done';

  @override
  String get tourStep1Title => 'Welcome to LumiLivre!';

  @override
  String get tourStep1Body =>
      'Discover and keep track of your library\'s books all in one place.';

  @override
  String get tourStep2Title => 'Explore the collection';

  @override
  String get tourStep2Body =>
      'Browse the Catalog or filter by Categories to find your next read.';

  @override
  String get tourStep3Title => 'Search and stay in the loop';

  @override
  String get tourStep3Body =>
      'Use search to find titles quickly and check the Board for news and announcements.';

  @override
  String get tourStep4Title => 'Your space';

  @override
  String get tourStep4Body =>
      'In your Profile you can track loans, change your photo and adjust your preferences.';
}
