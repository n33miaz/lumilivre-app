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
  String get languageSpanish => 'Spanish (Spain)';

  @override
  String get languageChinese => 'Chinese (Simplified)';

  @override
  String get languageHindi => 'Hindi (India)';

  @override
  String get biometricAccess => 'Biometric access';

  @override
  String get biometricSubtitle => 'Sign in with fingerprint or face.';

  @override
  String get biometricUnavailable =>
      'Biometrics are not available on this device.';

  @override
  String get biometricEnablePrompt =>
      'Confirm your identity to turn on biometric access.';

  @override
  String get biometricUnlockPrompt =>
      'Confirm your identity to continue in LumiLivre.';

  @override
  String get biometricEnableFailed =>
      'We could not confirm your identity. Biometrics stay off.';

  @override
  String get biometricEnabledConfirmation =>
      'Biometrics enabled. You will be asked for it the next time the app opens.';

  @override
  String get changePassword => 'Change password';

  @override
  String get logout => 'Sign out';

  @override
  String get guestSettingsPrompt => 'Sign in to access all settings';

  @override
  String get loginAction => 'Sign in';

  @override
  String get guestName => 'Guest';

  @override
  String get guestAccessDisabled =>
      'Guest access is turned off for this library.';

  @override
  String get retryAction => 'Try again';

  @override
  String get sessionExpiredMessage =>
      'Your session expired. Sign in again to continue.';

  @override
  String get connectionErrorMessage =>
      'Couldn\'t reach the server. Check your connection and try again.';

  @override
  String get loginFailedMessage =>
      'Couldn\'t sign you in. Check your ID number and password.';

  @override
  String get linkOpenError => 'Couldn\'t open the link on this device.';

  @override
  String get offlineCachedDataMessage => 'Offline: showing saved data.';

  @override
  String get catalogRefreshError => 'Couldn\'t refresh the catalog.';

  @override
  String get bookListLoadError =>
      'Couldn\'t load the books. Check your connection.';

  @override
  String get loadMoreError => 'Couldn\'t load more items.';

  @override
  String get searchError => 'Couldn\'t search for books right now.';

  @override
  String get passwordChangedMessage => 'Password changed.';

  @override
  String get passwordChangeFailedMessage =>
      'Couldn\'t change the password. Please try again.';

  @override
  String get passwordChangeRequiredMessage =>
      'Change your initial password to use this feature.';

  @override
  String get avatarUploading => 'Uploading photo...';

  @override
  String get avatarUploadSuccess => 'Photo updated.';

  @override
  String get avatarUploadError => 'Couldn\'t update the photo.';

  @override
  String get loanRequestSent =>
      'Request sent. The library will review it shortly.';

  @override
  String get loanRequestFailed => 'Couldn\'t request this book right now.';

  @override
  String get penaltyNoticeTitle => 'Loans paused for now';

  @override
  String penaltyNoticeUntil(String date) {
    return 'You can request books again on $date.';
  }

  @override
  String penaltyNoticeKind(String kind) {
    return 'Recorded as: $kind';
  }

  @override
  String get penaltyNoticeHint =>
      'Until then you can still browse the catalog and like books. If anything looks wrong, talk to the library.';

  @override
  String get bookDetailsLoadError => 'Couldn\'t load the book details.';

  @override
  String get guestBookTitle => 'Sign in to see this book';

  @override
  String get guestBookMessage =>
      'Full details, availability and loans are for library readers.';

  @override
  String get profileTabLoans => 'Loans';

  @override
  String get profileTabLikes => 'Likes';

  @override
  String get profileTabRanking => 'Ranking';

  @override
  String get guestLoansTitle => 'Sign in to see your loans';

  @override
  String get guestLoansMessage =>
      'Keep track of your active loans and history.';

  @override
  String get guestLikesTitle => 'Sign in to like books';

  @override
  String get guestLikesMessage =>
      'Save your favorite books to check them later.';

  @override
  String get guestRankingTitle => 'Sign in to see the ranking';

  @override
  String get guestRankingMessage =>
      'Compare your reading in the readers ranking.';

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

  @override
  String get cancelAction => 'CANCEL';

  @override
  String get saveAction => 'SAVE';

  @override
  String get refreshAction => 'Refresh';

  @override
  String get logoSemanticLabel => 'LumiLivre logo';

  @override
  String get loginSubmit => 'SIGN IN';

  @override
  String get loginAsGuest => 'CONTINUE AS GUEST';

  @override
  String get loginUserFieldLabel => 'ID number or email';

  @override
  String get loginUserFieldRequired => 'Enter your username';

  @override
  String get loginPasswordRequired => 'Enter your password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get passwordLabel => 'Password';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get mandatoryPasswordTitle => 'Change Your First Password';

  @override
  String get mandatoryPasswordMessage =>
      'For your security, change your current login password before continuing.';

  @override
  String get currentPasswordLabel => 'Current Password';

  @override
  String get currentPasswordRequired => 'Enter your current password';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get newPasswordRequired => 'Enter the new password';

  @override
  String get confirmNewPasswordLabel => 'Confirm New Password';

  @override
  String get passwordsDoNotMatch => 'The passwords don\'t match';

  @override
  String passwordMinLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'At least $count characters',
      one: 'At least 1 character',
    );
    return '$_temp0';
  }

  @override
  String get awaitingPasswordChange => 'Waiting for the password change...';

  @override
  String get navCategories => 'Categories';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navProfile => 'Profile';

  @override
  String get searchHint => 'Search for a book or author';

  @override
  String searchResultsTitle(String query) {
    return 'Results for \"$query\"';
  }

  @override
  String get searchNoResults => 'No books found.';

  @override
  String get browseAllTitle => 'Browse all';

  @override
  String get genreThesis => 'Theses';

  @override
  String get genreAdventure => 'Adventure';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreEducational => 'Educational';

  @override
  String get genreThriller => 'Thriller';

  @override
  String get genreBiography => 'Biography';

  @override
  String get genreFiction => 'Fiction';

  @override
  String get genreHistory => 'History';

  @override
  String get genreSelfHelp => 'Self-help';

  @override
  String get genreFantasy => 'Fantasy';

  @override
  String get genreHorror => 'Horror';

  @override
  String get genrePoetry => 'Poetry';

  @override
  String get genreScienceTechnology => 'Science and Technology';

  @override
  String get genreChildrenAndTeens => 'Children and Teens';

  @override
  String get categoryEmptyTitle => 'No books found';

  @override
  String categoryEmptyMessage(String category) {
    return 'There are no books in \"$category\" yet.\nCheck back soon for new additions!';
  }

  @override
  String get categoryExploreOthers => 'EXPLORE OTHERS';

  @override
  String get bookDetailsTitle => 'Details';

  @override
  String get bookCoverMissing => 'No Cover';

  @override
  String bookReleasedOn(String date) {
    return 'Released on $date';
  }

  @override
  String get bookRatingsLabel => 'Ratings';

  @override
  String get bookCoverTypeLabel => 'Cover Type';

  @override
  String get bookAgeRatingLabel => 'Age Rating';

  @override
  String get bookPublisherLabel => 'Publisher';

  @override
  String get bookGenresLabel => 'Genres';

  @override
  String get bookSynopsisLabel => 'Synopsis';

  @override
  String get loanButtonGuest => 'SIGN IN TO REQUEST';

  @override
  String get loanButtonNoCopies => 'NO COPIES REGISTERED';

  @override
  String get loanButtonLimitReached => 'LOAN LIMIT REACHED';

  @override
  String get loanButtonRequest => 'REQUEST LOAN';

  @override
  String get loanButtonPending => 'AWAITING APPROVAL';

  @override
  String loanButtonActiveUntil(String date) {
    return 'IN USE UNTIL: $date';
  }

  @override
  String get loanButtonOverdue => 'RETURN OVERDUE';

  @override
  String loanButtonAvailableFrom(String date) {
    return 'AVAILABLE FROM: $date';
  }

  @override
  String get loanButtonUnavailable => 'CURRENTLY UNAVAILABLE';

  @override
  String get loansTabInProgress => 'In Progress';

  @override
  String get loansTabHistory => 'History';

  @override
  String get loansHistoryEmpty => 'No history found.';

  @override
  String get loansActiveEmpty => 'No active loans or requests.';

  @override
  String get loanStatusRejected => 'Request Declined';

  @override
  String get loanStatusPending => 'Awaiting Approval';

  @override
  String get loanStatusReturned => 'Returned';

  @override
  String loanStatusOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Overdue ($count days)',
      one: 'Overdue (1 day)',
    );
    return '$_temp0';
  }

  @override
  String get loanStatusDueToday => 'Due Today!';

  @override
  String loanStatusDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Due in $count days',
      one: 'Due in 1 day',
    );
    return '$_temp0';
  }

  @override
  String loanRequestedOn(String date) {
    return 'Requested on: $date';
  }

  @override
  String loanBorrowedOn(String date) {
    return 'Borrowed on: $date';
  }

  @override
  String get likesEmptyMessage => 'You haven\'t liked any books yet.';

  @override
  String profileSubtitleWithRank(String registration, String rank) {
    return '$registration - Ranking: $rank';
  }

  @override
  String get offlineBannerMessage => 'You\'re offline. Showing saved data.';

  @override
  String get likeAction => 'Like';

  @override
  String get unlikeAction => 'Remove from likes';

  @override
  String get interestOfflineError => 'No connection: your like wasn\'t saved.';

  @override
  String get interestSaveError => 'Couldn\'t save your like. Try again.';

  @override
  String interestMigratedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count books liked on this device were saved to your account.',
      one: '1 book liked on this device was saved to your account.',
    );
    return '$_temp0';
  }
}
