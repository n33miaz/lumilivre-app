import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'LumiLivre'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Configurações'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In pt, this message translates to:
  /// **'Aparência'**
  String get appearanceSection;

  /// No description provided for @languageSection.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get languageSection;

  /// No description provided for @securitySection.
  ///
  /// In pt, this message translates to:
  /// **'Segurança'**
  String get securitySection;

  /// No description provided for @accountSection.
  ///
  /// In pt, this message translates to:
  /// **'Conta'**
  String get accountSection;

  /// No description provided for @themeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tema'**
  String get themeLabel;

  /// No description provided for @themeLight.
  ///
  /// In pt, this message translates to:
  /// **'Claro'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In pt, this message translates to:
  /// **'Sistema'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In pt, this message translates to:
  /// **'Escuro'**
  String get themeDark;

  /// No description provided for @languagePortuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português (Brasil)'**
  String get languagePortuguese;

  /// No description provided for @languageEnglish.
  ///
  /// In pt, this message translates to:
  /// **'English (US)'**
  String get languageEnglish;

  /// No description provided for @biometricAccess.
  ///
  /// In pt, this message translates to:
  /// **'Acesso com biometria'**
  String get biometricAccess;

  /// No description provided for @biometricSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com digital ou rosto.'**
  String get biometricSubtitle;

  /// No description provided for @biometricUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Biometria não disponível neste dispositivo.'**
  String get biometricUnavailable;

  /// No description provided for @biometricEnablePrompt.
  ///
  /// In pt, this message translates to:
  /// **'Confirme sua identidade para ativar o acesso com biometria.'**
  String get biometricEnablePrompt;

  /// No description provided for @biometricUnlockPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Confirme sua identidade para continuar no LumiLivre.'**
  String get biometricUnlockPrompt;

  /// No description provided for @biometricEnableFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível confirmar sua identidade. A biometria continua desligada.'**
  String get biometricEnableFailed;

  /// No description provided for @biometricEnabledConfirmation.
  ///
  /// In pt, this message translates to:
  /// **'Biometria ativada. Ela será pedida na próxima abertura do app.'**
  String get biometricEnabledConfirmation;

  /// No description provided for @changePassword.
  ///
  /// In pt, this message translates to:
  /// **'Mudar senha'**
  String get changePassword;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get logout;

  /// No description provided for @guestSettingsPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para acessar todas as configurações'**
  String get guestSettingsPrompt;

  /// No description provided for @loginAction.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginAction;

  /// No description provided for @readerTerm.
  ///
  /// In pt, this message translates to:
  /// **'Leitor'**
  String get readerTerm;

  /// No description provided for @filterRanking.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar Ranking'**
  String get filterRanking;

  /// No description provided for @courseLabel.
  ///
  /// In pt, this message translates to:
  /// **'Curso'**
  String get courseLabel;

  /// No description provided for @moduleLabel.
  ///
  /// In pt, this message translates to:
  /// **'Módulo'**
  String get moduleLabel;

  /// No description provided for @shiftLabel.
  ///
  /// In pt, this message translates to:
  /// **'Turno'**
  String get shiftLabel;

  /// No description provided for @applyFilters.
  ///
  /// In pt, this message translates to:
  /// **'APLICAR FILTROS'**
  String get applyFilters;

  /// No description provided for @clearFilters.
  ///
  /// In pt, this message translates to:
  /// **'Limpar Filtros'**
  String get clearFilters;

  /// No description provided for @emptyRankingMessage.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum leitor encontrado.'**
  String get emptyRankingMessage;

  /// No description provided for @rankingLoginPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para ver o ranking.'**
  String get rankingLoginPrompt;

  /// No description provided for @rankingUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Ranking indisponível para esta biblioteca.'**
  String get rankingUnavailable;

  /// No description provided for @muralTitle.
  ///
  /// In pt, this message translates to:
  /// **'Mural'**
  String get muralTitle;

  /// No description provided for @muralEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma publicação por aqui ainda.'**
  String get muralEmpty;

  /// No description provided for @muralError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o mural. Verifique sua conexão.'**
  String get muralError;

  /// No description provided for @muralRetry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get muralRetry;

  /// No description provided for @muralLoginPrompt.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para ver o mural.'**
  String get muralLoginPrompt;

  /// No description provided for @muralTypeAnnouncement.
  ///
  /// In pt, this message translates to:
  /// **'Comunicado'**
  String get muralTypeAnnouncement;

  /// No description provided for @muralTypeAttachment.
  ///
  /// In pt, this message translates to:
  /// **'Anexo'**
  String get muralTypeAttachment;

  /// No description provided for @muralTypeWork.
  ///
  /// In pt, this message translates to:
  /// **'Trabalho'**
  String get muralTypeWork;

  /// No description provided for @muralOpenDocument.
  ///
  /// In pt, this message translates to:
  /// **'Abrir documento'**
  String get muralOpenDocument;

  /// No description provided for @muralExternalLink.
  ///
  /// In pt, this message translates to:
  /// **'Link externo'**
  String get muralExternalLink;

  /// No description provided for @muralByAuthors.
  ///
  /// In pt, this message translates to:
  /// **'por {authors}'**
  String muralByAuthors(String authors);

  /// No description provided for @muralAuthorsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Autor(es)'**
  String get muralAuthorsLabel;

  /// No description provided for @muralAdvisorsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Orientador(es)'**
  String get muralAdvisorsLabel;

  /// No description provided for @muralYearLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ano'**
  String get muralYearLabel;

  /// No description provided for @muralSemesterLabel.
  ///
  /// In pt, this message translates to:
  /// **'Semestre'**
  String get muralSemesterLabel;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In pt, this message translates to:
  /// **'Atualize o aplicativo'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateMessage.
  ///
  /// In pt, this message translates to:
  /// **'Uma nova versão obrigatória está disponível. Atualize para continuar usando o LumiLivre.'**
  String get forceUpdateMessage;

  /// No description provided for @forceUpdateButton.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar agora'**
  String get forceUpdateButton;

  /// No description provided for @forceUpdateStoreError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir a loja de aplicativos.'**
  String get forceUpdateStoreError;

  /// No description provided for @tourSkip.
  ///
  /// In pt, this message translates to:
  /// **'Pular'**
  String get tourSkip;

  /// No description provided for @tourNext.
  ///
  /// In pt, this message translates to:
  /// **'Próximo'**
  String get tourNext;

  /// No description provided for @tourFinish.
  ///
  /// In pt, this message translates to:
  /// **'Concluir'**
  String get tourFinish;

  /// No description provided for @tourStep1Title.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo(a) ao LumiLivre!'**
  String get tourStep1Title;

  /// No description provided for @tourStep1Body.
  ///
  /// In pt, this message translates to:
  /// **'Descubra e acompanhe os livros da sua biblioteca em um só lugar.'**
  String get tourStep1Body;

  /// No description provided for @tourStep2Title.
  ///
  /// In pt, this message translates to:
  /// **'Explore o acervo'**
  String get tourStep2Title;

  /// No description provided for @tourStep2Body.
  ///
  /// In pt, this message translates to:
  /// **'Navegue pelo Catálogo ou filtre por Categorias para encontrar sua próxima leitura.'**
  String get tourStep2Body;

  /// No description provided for @tourStep3Title.
  ///
  /// In pt, this message translates to:
  /// **'Busque e fique por dentro'**
  String get tourStep3Title;

  /// No description provided for @tourStep3Body.
  ///
  /// In pt, this message translates to:
  /// **'Use a busca para achar títulos rapidamente e confira o Mural para novidades e comunicados.'**
  String get tourStep3Body;

  /// No description provided for @tourStep4Title.
  ///
  /// In pt, this message translates to:
  /// **'Seu espaço'**
  String get tourStep4Title;

  /// No description provided for @tourStep4Body.
  ///
  /// In pt, this message translates to:
  /// **'No Perfil você acompanha empréstimos, troca sua foto e ajusta suas preferências.'**
  String get tourStep4Body;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
