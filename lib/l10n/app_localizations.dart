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

  /// No description provided for @guestName.
  ///
  /// In pt, this message translates to:
  /// **'Convidado'**
  String get guestName;

  /// No description provided for @guestAccessDisabled.
  ///
  /// In pt, this message translates to:
  /// **'O acesso de convidado está desativado nesta biblioteca.'**
  String get guestAccessDisabled;

  /// No description provided for @retryAction.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retryAction;

  /// No description provided for @sessionExpiredMessage.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão expirou. Entre novamente para continuar.'**
  String get sessionExpiredMessage;

  /// No description provided for @connectionErrorMessage.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível falar com o servidor. Verifique sua conexão e tente de novo.'**
  String get connectionErrorMessage;

  /// No description provided for @loginFailedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível entrar. Confira a matrícula e a senha.'**
  String get loginFailedMessage;

  /// No description provided for @linkOpenError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível abrir o link neste aparelho.'**
  String get linkOpenError;

  /// No description provided for @offlineCachedDataMessage.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão: mostrando os dados salvos.'**
  String get offlineCachedDataMessage;

  /// No description provided for @catalogRefreshError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar o catálogo.'**
  String get catalogRefreshError;

  /// No description provided for @bookListLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os livros. Verifique sua conexão.'**
  String get bookListLoadError;

  /// No description provided for @loadMoreError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar mais itens.'**
  String get loadMoreError;

  /// No description provided for @searchError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível buscar livros agora.'**
  String get searchError;

  /// No description provided for @passwordChangedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Senha alterada.'**
  String get passwordChangedMessage;

  /// No description provided for @passwordChangeFailedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível alterar a senha. Tente novamente.'**
  String get passwordChangeFailedMessage;

  /// No description provided for @passwordChangeRequiredMessage.
  ///
  /// In pt, this message translates to:
  /// **'Troque sua senha inicial para usar esta função.'**
  String get passwordChangeRequiredMessage;

  /// No description provided for @avatarUploading.
  ///
  /// In pt, this message translates to:
  /// **'Enviando foto...'**
  String get avatarUploading;

  /// No description provided for @avatarUploadSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Foto atualizada.'**
  String get avatarUploadSuccess;

  /// No description provided for @avatarUploadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar a foto.'**
  String get avatarUploadError;

  /// No description provided for @loanRequestSent.
  ///
  /// In pt, this message translates to:
  /// **'Solicitação enviada. Aguarde a aprovação da biblioteca.'**
  String get loanRequestSent;

  /// No description provided for @loanRequestFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível solicitar este livro agora.'**
  String get loanRequestFailed;

  /// No description provided for @penaltyNoticeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Empréstimos pausados por enquanto'**
  String get penaltyNoticeTitle;

  /// No description provided for @penaltyNoticeUntil.
  ///
  /// In pt, this message translates to:
  /// **'Você volta a solicitar livros em {date}.'**
  String penaltyNoticeUntil(String date);

  /// No description provided for @penaltyNoticeKind.
  ///
  /// In pt, this message translates to:
  /// **'Registrado como: {kind}'**
  String penaltyNoticeKind(String kind);

  /// No description provided for @penaltyNoticeHint.
  ///
  /// In pt, this message translates to:
  /// **'Até lá você continua explorando o catálogo e curtindo livros. Se tiver alguma dúvida, fale com a biblioteca.'**
  String get penaltyNoticeHint;

  /// No description provided for @bookDetailsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os detalhes do livro.'**
  String get bookDetailsLoadError;

  /// No description provided for @guestBookTitle.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para ver este livro'**
  String get guestBookTitle;

  /// No description provided for @guestBookMessage.
  ///
  /// In pt, this message translates to:
  /// **'A ficha completa, a disponibilidade e o empréstimo são para leitores da biblioteca.'**
  String get guestBookMessage;

  /// No description provided for @profileTabLoans.
  ///
  /// In pt, this message translates to:
  /// **'Empréstimos'**
  String get profileTabLoans;

  /// No description provided for @profileTabLikes.
  ///
  /// In pt, this message translates to:
  /// **'Curtidos'**
  String get profileTabLikes;

  /// No description provided for @profileTabRanking.
  ///
  /// In pt, this message translates to:
  /// **'Ranking'**
  String get profileTabRanking;

  /// No description provided for @guestLoansTitle.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para ver seus empréstimos'**
  String get guestLoansTitle;

  /// No description provided for @guestLoansMessage.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe seus empréstimos ativos e o histórico.'**
  String get guestLoansMessage;

  /// No description provided for @guestLikesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para curtir livros'**
  String get guestLikesTitle;

  /// No description provided for @guestLikesMessage.
  ///
  /// In pt, this message translates to:
  /// **'Salve seus livros favoritos para acompanhar depois.'**
  String get guestLikesMessage;

  /// No description provided for @guestRankingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para ver o ranking'**
  String get guestRankingTitle;

  /// No description provided for @guestRankingMessage.
  ///
  /// In pt, this message translates to:
  /// **'Compare suas leituras no ranking de leitores.'**
  String get guestRankingMessage;

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
