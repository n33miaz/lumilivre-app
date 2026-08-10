// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'LumiLivre';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get appearanceSection => 'दिखावट';

  @override
  String get languageSection => 'भाषा';

  @override
  String get securitySection => 'सुरक्षा';

  @override
  String get accountSection => 'खाता';

  @override
  String get themeLabel => 'थीम';

  @override
  String get themeLight => 'हल्की';

  @override
  String get themeSystem => 'सिस्टम';

  @override
  String get themeDark => 'गहरी';

  @override
  String get languagePortuguese => 'पुर्तगाली (ब्राज़ील)';

  @override
  String get languageEnglish => 'अंग्रेज़ी (अमेरिका)';

  @override
  String get languageSpanish => 'स्पेनिश (स्पेन)';

  @override
  String get languageChinese => 'चीनी (सरलीकृत)';

  @override
  String get languageHindi => 'हिन्दी (भारत)';

  @override
  String get biometricAccess => 'बायोमेट्रिक प्रवेश';

  @override
  String get biometricSubtitle => 'फ़िंगरप्रिंट या चेहरे से लॉग इन करें।';

  @override
  String get biometricUnavailable => 'इस डिवाइस पर बायोमेट्रिक उपलब्ध नहीं है।';

  @override
  String get biometricEnablePrompt =>
      'बायोमेट्रिक प्रवेश चालू करने के लिए अपनी पहचान सत्यापित करें।';

  @override
  String get biometricUnlockPrompt =>
      'LumiLivre में जारी रखने के लिए अपनी पहचान सत्यापित करें।';

  @override
  String get biometricEnableFailed =>
      'हम आपकी पहचान सत्यापित नहीं कर सके। बायोमेट्रिक बंद ही रहेगा।';

  @override
  String get biometricEnabledConfirmation =>
      'बायोमेट्रिक चालू हो गया। अगली बार ऐप खोलने पर यह पूछा जाएगा।';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get logout => 'खाते से लॉग आउट करें';

  @override
  String get guestSettingsPrompt => 'सभी सेटिंग्स के लिए लॉग इन करें';

  @override
  String get loginAction => 'लॉग इन करें';

  @override
  String get guestName => 'अतिथि';

  @override
  String get guestAccessDisabled => 'इस पुस्तकालय में अतिथि प्रवेश बंद है।';

  @override
  String get retryAction => 'पुनः प्रयास करें';

  @override
  String get sessionExpiredMessage =>
      'आपका सत्र समाप्त हो गया। जारी रखने के लिए फिर लॉग इन करें।';

  @override
  String get connectionErrorMessage =>
      'सर्वर से संपर्क नहीं हो सका। अपना कनेक्शन जाँचें और पुनः प्रयास करें।';

  @override
  String get loginFailedMessage =>
      'लॉग इन नहीं हो सका। नामांकन संख्या और पासवर्ड जाँचें।';

  @override
  String get linkOpenError => 'इस डिवाइस पर लिंक नहीं खुल सका।';

  @override
  String get offlineCachedDataMessage =>
      'कनेक्शन नहीं है: सहेजा गया डेटा दिखा रहे हैं।';

  @override
  String get catalogRefreshError => 'कैटलॉग अद्यतन नहीं हो सका।';

  @override
  String get bookListLoadError =>
      'किताबें लोड नहीं हो सकीं। अपना कनेक्शन जाँचें।';

  @override
  String get loadMoreError => 'और आइटम लोड नहीं हो सके।';

  @override
  String get searchError => 'अभी किताबें नहीं खोजी जा सकतीं।';

  @override
  String get passwordChangedMessage => 'पासवर्ड बदल गया।';

  @override
  String get passwordChangeFailedMessage =>
      'पासवर्ड नहीं बदला जा सका। पुनः प्रयास करें।';

  @override
  String get passwordChangeRequiredMessage =>
      'इस सुविधा के लिए पहले अपना शुरुआती पासवर्ड बदलें।';

  @override
  String get avatarUploading => 'फ़ोटो भेजी जा रही है...';

  @override
  String get avatarUploadSuccess => 'फ़ोटो अद्यतन हो गई।';

  @override
  String get avatarUploadError => 'फ़ोटो अद्यतन नहीं हो सकी।';

  @override
  String get loanRequestSent =>
      'अनुरोध भेज दिया गया। पुस्तकालय की स्वीकृति की प्रतीक्षा करें।';

  @override
  String get loanRequestFailed => 'अभी इस किताब का अनुरोध नहीं किया जा सकता।';

  @override
  String get penaltyNoticeTitle => 'फ़िलहाल ऋण रोक दिए गए हैं';

  @override
  String penaltyNoticeUntil(String date) {
    return 'आप $date से फिर किताबें ले सकेंगे।';
  }

  @override
  String penaltyNoticeKind(String kind) {
    return 'इस रूप में दर्ज: $kind';
  }

  @override
  String get penaltyNoticeHint =>
      'तब तक आप कैटलॉग देख सकते हैं और किताबें पसंद कर सकते हैं। कोई सवाल हो तो पुस्तकालय से बात करें।';

  @override
  String get bookDetailsLoadError => 'किताब का विवरण लोड नहीं हो सका।';

  @override
  String get guestBookTitle => 'यह किताब देखने के लिए लॉग इन करें';

  @override
  String get guestBookMessage =>
      'पूरा विवरण, उपलब्धता और ऋण पुस्तकालय के पाठकों के लिए हैं।';

  @override
  String get profileTabLoans => 'ऋण';

  @override
  String get profileTabLikes => 'पसंदीदा';

  @override
  String get profileTabRanking => 'रैंकिंग';

  @override
  String get guestLoansTitle => 'अपने ऋण देखने के लिए लॉग इन करें';

  @override
  String get guestLoansMessage => 'अपने चालू ऋण और इतिहास पर नज़र रखें।';

  @override
  String get guestLikesTitle => 'किताबें पसंद करने के लिए लॉग इन करें';

  @override
  String get guestLikesMessage =>
      'अपनी पसंदीदा किताबें सहेजें और बाद में देखें।';

  @override
  String get guestRankingTitle => 'रैंकिंग देखने के लिए लॉग इन करें';

  @override
  String get guestRankingMessage =>
      'पाठकों की रैंकिंग में अपनी पढ़ाई की तुलना करें।';

  @override
  String get readerTerm => 'पाठक';

  @override
  String get filterRanking => 'रैंकिंग फ़िल्टर करें';

  @override
  String get courseLabel => 'पाठ्यक्रम';

  @override
  String get moduleLabel => 'मॉड्यूल';

  @override
  String get shiftLabel => 'पारी';

  @override
  String get applyFilters => 'फ़िल्टर लागू करें';

  @override
  String get clearFilters => 'फ़िल्टर साफ़ करें';

  @override
  String get emptyRankingMessage => 'कोई पाठक नहीं मिला।';

  @override
  String get rankingLoginPrompt => 'रैंकिंग देखने के लिए लॉग इन करें।';

  @override
  String get rankingUnavailable =>
      'इस पुस्तकालय के लिए रैंकिंग उपलब्ध नहीं है।';

  @override
  String get muralTitle => 'सूचना पट्ट';

  @override
  String get muralEmpty => 'यहाँ अभी कोई प्रकाशन नहीं है।';

  @override
  String get muralError => 'सूचना पट्ट लोड नहीं हो सका। अपना कनेक्शन जाँचें।';

  @override
  String get muralRetry => 'पुनः प्रयास करें';

  @override
  String get muralLoginPrompt => 'सूचना पट्ट देखने के लिए लॉग इन करें।';

  @override
  String get muralTypeAnnouncement => 'सूचना';

  @override
  String get muralTypeAttachment => 'संलग्नक';

  @override
  String get muralTypeWork => 'कार्य';

  @override
  String get muralOpenDocument => 'दस्तावेज़ खोलें';

  @override
  String get muralExternalLink => 'बाहरी लिंक';

  @override
  String muralByAuthors(String authors) {
    return '$authors द्वारा';
  }

  @override
  String get muralAuthorsLabel => 'लेखक';

  @override
  String get muralAdvisorsLabel => 'मार्गदर्शक';

  @override
  String get muralYearLabel => 'वर्ष';

  @override
  String get muralSemesterLabel => 'सत्र';

  @override
  String muralUnseenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count नए प्रकाशन',
      one: '$count नया प्रकाशन',
    );
    return '$_temp0';
  }

  @override
  String get forceUpdateTitle => 'ऐप अद्यतन करें';

  @override
  String get forceUpdateMessage =>
      'एक नया अनिवार्य संस्करण उपलब्ध है। LumiLivre का उपयोग जारी रखने के लिए अद्यतन करें।';

  @override
  String get forceUpdateButton => 'अभी अद्यतन करें';

  @override
  String get forceUpdateStoreError => 'ऐप स्टोर नहीं खुल सका।';

  @override
  String get tourSkip => 'छोड़ें';

  @override
  String get tourNext => 'आगे';

  @override
  String get tourFinish => 'समाप्त';

  @override
  String get tourStep1Title => 'LumiLivre में आपका स्वागत है!';

  @override
  String get tourStep1Body =>
      'अपने पुस्तकालय की किताबें एक ही जगह खोजें और उन पर नज़र रखें।';

  @override
  String get tourStep2Title => 'संग्रह देखें';

  @override
  String get tourStep2Body =>
      'कैटलॉग में घूमें या श्रेणियों से छानकर अपनी अगली किताब चुनें।';

  @override
  String get tourStep3Title => 'खोजें और अद्यतन रहें';

  @override
  String get tourStep3Body =>
      'खोज से किताबें तुरंत ढूँढें और नई सूचनाओं के लिए सूचना पट्ट देखें।';

  @override
  String get tourStep4Title => 'आपकी जगह';

  @override
  String get tourStep4Body =>
      'प्रोफ़ाइल में आप ऋण देखते हैं, फ़ोटो बदलते हैं और अपनी पसंद तय करते हैं।';

  @override
  String get cancelAction => 'रद्द करें';

  @override
  String get saveAction => 'सहेजें';

  @override
  String get refreshAction => 'अद्यतन करें';

  @override
  String get logoSemanticLabel => 'LumiLivre लोगो';

  @override
  String get loginSubmit => 'लॉग इन करें';

  @override
  String get loginAsGuest => 'अतिथि के रूप में प्रवेश करें';

  @override
  String get loginUserFieldLabel => 'नामांकन संख्या या ईमेल';

  @override
  String get loginUserFieldRequired => 'अपना उपयोगकर्ता नाम लिखें';

  @override
  String get loginPasswordRequired => 'अपना पासवर्ड लिखें';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get changePasswordTitle => 'पासवर्ड बदलें';

  @override
  String get mandatoryPasswordTitle => 'पहला पासवर्ड बदलें';

  @override
  String get mandatoryPasswordMessage =>
      'आपकी सुरक्षा के लिए, जारी रखने से पहले अपना वर्तमान लॉगिन पासवर्ड बदलें।';

  @override
  String get currentPasswordLabel => 'वर्तमान पासवर्ड';

  @override
  String get currentPasswordRequired => 'वर्तमान पासवर्ड बताएँ';

  @override
  String get newPasswordLabel => 'नया पासवर्ड';

  @override
  String get newPasswordRequired => 'नया पासवर्ड बताएँ';

  @override
  String get confirmNewPasswordLabel => 'नया पासवर्ड पुष्ट करें';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते';

  @override
  String passwordMinLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'कम से कम $count अक्षर',
      one: 'कम से कम $count अक्षर',
    );
    return '$_temp0';
  }

  @override
  String get awaitingPasswordChange => 'पासवर्ड बदलने की प्रतीक्षा...';

  @override
  String get navCategories => 'श्रेणियाँ';

  @override
  String get navCatalog => 'कैटलॉग';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get searchHint => 'किताब या लेखक खोजें';

  @override
  String searchResultsTitle(String query) {
    return '\"$query\" के परिणाम';
  }

  @override
  String get searchNoResults => 'कोई किताब नहीं मिली।';

  @override
  String get browseAllTitle => 'सभी श्रेणियाँ देखें';

  @override
  String get genreThesis => 'शोध-प्रबंध';

  @override
  String get genreAdventure => 'साहसिक';

  @override
  String get genreRomance => 'प्रेमकथा';

  @override
  String get genreEducational => 'शैक्षिक';

  @override
  String get genreThriller => 'रहस्य-रोमांच';

  @override
  String get genreBiography => 'जीवनी';

  @override
  String get genreFiction => 'कथा-साहित्य';

  @override
  String get genreHistory => 'इतिहास';

  @override
  String get genreSelfHelp => 'स्वयं-सहायता';

  @override
  String get genreFantasy => 'फ़ैंटेसी';

  @override
  String get genreHorror => 'डरावनी';

  @override
  String get genrePoetry => 'कविता';

  @override
  String get genreScienceTechnology => 'विज्ञान और तकनीक';

  @override
  String get genreChildrenAndTeens => 'बाल एवं किशोर';

  @override
  String get categoryEmptyTitle => 'कोई किताब नहीं मिली';

  @override
  String categoryEmptyMessage(String category) {
    return '\"$category\" में अभी कोई किताब दर्ज नहीं है।\nनई किताबों के लिए जल्द ही फिर आएँ!';
  }

  @override
  String get categoryExploreOthers => 'अन्य श्रेणियाँ देखें';

  @override
  String get bookDetailsTitle => 'विवरण';

  @override
  String get bookCoverMissing => 'आवरण नहीं';

  @override
  String bookReleasedOn(String date) {
    return '$date को प्रकाशित';
  }

  @override
  String get bookRatingsLabel => 'रेटिंग';

  @override
  String get bookCoverTypeLabel => 'आवरण का प्रकार';

  @override
  String get bookAgeRatingLabel => 'आयु वर्ग';

  @override
  String get bookPublisherLabel => 'प्रकाशक';

  @override
  String get bookGenresLabel => 'श्रेणियाँ';

  @override
  String get bookSynopsisLabel => 'सारांश';

  @override
  String get loanButtonGuest => 'अनुरोध के लिए लॉग इन करें';

  @override
  String get loanButtonNoCopies => 'कोई प्रति दर्ज नहीं';

  @override
  String get loanButtonLimitReached => 'ऋण की सीमा पूरी';

  @override
  String get loanButtonRequest => 'ऋण का अनुरोध करें';

  @override
  String get loanButtonPending => 'स्वीकृति की प्रतीक्षा';

  @override
  String loanButtonActiveUntil(String date) {
    return '$date तक आपके पास';
  }

  @override
  String get loanButtonOverdue => 'वापसी की तारीख़ बीत चुकी';

  @override
  String loanButtonAvailableFrom(String date) {
    return '$date से उपलब्ध';
  }

  @override
  String get loanButtonUnavailable => 'इस समय उपलब्ध नहीं';

  @override
  String get loansTabInProgress => 'चालू';

  @override
  String get loansTabHistory => 'इतिहास';

  @override
  String get loansHistoryEmpty => 'कोई इतिहास नहीं मिला।';

  @override
  String get loansActiveEmpty => 'कोई चालू ऋण या अनुरोध नहीं।';

  @override
  String get loanStatusRejected => 'अनुरोध अस्वीकृत';

  @override
  String get loanStatusPending => 'स्वीकृति की प्रतीक्षा';

  @override
  String get loanStatusReturned => 'वापस कर दी';

  @override
  String loanStatusOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन विलंबित',
      one: '$count दिन विलंबित',
    );
    return '$_temp0';
  }

  @override
  String get loanStatusDueToday => 'आज वापसी का दिन!';

  @override
  String loanStatusDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count दिन में वापसी',
      one: '$count दिन में वापसी',
    );
    return '$_temp0';
  }

  @override
  String loanRequestedOn(String date) {
    return 'अनुरोध किया: $date';
  }

  @override
  String loanBorrowedOn(String date) {
    return 'ऋण लिया: $date';
  }

  @override
  String get likesEmptyMessage => 'आपने अभी कोई किताब पसंद नहीं की।';

  @override
  String profileSubtitleWithRank(String registration, String rank) {
    return '$registration - रैंकिंग: $rank';
  }

  @override
  String get offlineBannerMessage =>
      'आप ऑफ़लाइन हैं। सहेजा गया डेटा दिख रहा है।';

  @override
  String apiHealthWakingBanner(String elapsed) {
    return 'सर्वर जाग रहा है… $elapsed';
  }

  @override
  String get apiHealthWakingToast =>
      'सर्वर निष्क्रिय था और अब चालू हो रहा है। इसमें 3 मिनट तक लग सकते हैं: ऐप अपने आप कोशिश करता रहता है और जवाब मिलते ही सामग्री लोड कर देता है।';

  @override
  String get apiHealthRestoredToast =>
      'सर्वर वापस आ गया। सामग्री लोड हो रही है।';

  @override
  String get apiHealthUnreachableBanner =>
      'सर्वर से कोई जवाब नहीं। दोबारा कोशिश करने के लिए टैप करें।';

  @override
  String get likeAction => 'पसंद करें';

  @override
  String get unlikeAction => 'पसंदीदा से हटाएँ';

  @override
  String get interestOfflineError =>
      'कनेक्शन नहीं है: आपकी पसंद सहेजी नहीं गई।';

  @override
  String get interestSaveError =>
      'आपकी पसंद सहेजी नहीं जा सकी। पुनः प्रयास करें।';

  @override
  String interestMigratedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'इस डिवाइस पर पसंद की गई $count किताबें आपके खाते में सहेजी गईं।',
      one: 'इस डिवाइस पर पसंद की गई $count किताब आपके खाते में सहेजी गई।',
    );
    return '$_temp0';
  }
}
