import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

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
    Locale('es'),
    Locale('hi'),
    Locale('pt'),
    Locale('zh'),
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

  /// No description provided for @languageSpanish.
  ///
  /// In pt, this message translates to:
  /// **'Espanhol (Espanha)'**
  String get languageSpanish;

  /// No description provided for @languageChinese.
  ///
  /// In pt, this message translates to:
  /// **'Chinês (simplificado)'**
  String get languageChinese;

  /// No description provided for @languageHindi.
  ///
  /// In pt, this message translates to:
  /// **'Hindi (Índia)'**
  String get languageHindi;

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

  /// No description provided for @muralUnseenCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 publicação nova} other{{count} publicações novas}}'**
  String muralUnseenCount(int count);

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

  /// No description provided for @cancelAction.
  ///
  /// In pt, this message translates to:
  /// **'CANCELAR'**
  String get cancelAction;

  /// No description provided for @saveAction.
  ///
  /// In pt, this message translates to:
  /// **'SALVAR'**
  String get saveAction;

  /// No description provided for @refreshAction.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar'**
  String get refreshAction;

  /// No description provided for @logoSemanticLabel.
  ///
  /// In pt, this message translates to:
  /// **'Logo LumiLivre'**
  String get logoSemanticLabel;

  /// No description provided for @loginSubmit.
  ///
  /// In pt, this message translates to:
  /// **'ENTRAR'**
  String get loginSubmit;

  /// No description provided for @loginAsGuest.
  ///
  /// In pt, this message translates to:
  /// **'ENTRAR COMO CONVIDADO'**
  String get loginAsGuest;

  /// No description provided for @loginUserFieldLabel.
  ///
  /// In pt, this message translates to:
  /// **'Matrícula ou Email'**
  String get loginUserFieldLabel;

  /// No description provided for @loginUserFieldRequired.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu usuário'**
  String get loginUserFieldRequired;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Digite sua senha'**
  String get loginPasswordRequired;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu sua senha?'**
  String get forgotPassword;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @changePasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterar Senha'**
  String get changePasswordTitle;

  /// No description provided for @mandatoryPasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alterar Primeira Senha'**
  String get mandatoryPasswordTitle;

  /// No description provided for @mandatoryPasswordMessage.
  ///
  /// In pt, this message translates to:
  /// **'Para sua segurança, altere sua senha atual de login antes de continuar.'**
  String get mandatoryPasswordMessage;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha Atual'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe a senha atual'**
  String get currentPasswordRequired;

  /// No description provided for @newPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nova Senha'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe a nova senha'**
  String get newPasswordRequired;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar Nova Senha'**
  String get confirmNewPasswordLabel;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não conferem'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordMinLength.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Mínimo de 1 caractere} other{Mínimo de {count} caracteres}}'**
  String passwordMinLength(int count);

  /// No description provided for @awaitingPasswordChange.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando alteração de senha...'**
  String get awaitingPasswordChange;

  /// No description provided for @navCategories.
  ///
  /// In pt, this message translates to:
  /// **'Categorias'**
  String get navCategories;

  /// No description provided for @navCatalog.
  ///
  /// In pt, this message translates to:
  /// **'Catálogo'**
  String get navCatalog;

  /// No description provided for @navProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get navProfile;

  /// No description provided for @searchHint.
  ///
  /// In pt, this message translates to:
  /// **'Procure por um livro ou autor'**
  String get searchHint;

  /// No description provided for @searchResultsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resultados para \"{query}\"'**
  String searchResultsTitle(String query);

  /// No description provided for @searchNoResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum livro encontrado.'**
  String get searchNoResults;

  /// No description provided for @browseAllTitle.
  ///
  /// In pt, this message translates to:
  /// **'Navegue por todos'**
  String get browseAllTitle;

  /// No description provided for @genreThesis.
  ///
  /// In pt, this message translates to:
  /// **'TCCs'**
  String get genreThesis;

  /// No description provided for @genreAdventure.
  ///
  /// In pt, this message translates to:
  /// **'Aventura'**
  String get genreAdventure;

  /// No description provided for @genreRomance.
  ///
  /// In pt, this message translates to:
  /// **'Romance'**
  String get genreRomance;

  /// No description provided for @genreEducational.
  ///
  /// In pt, this message translates to:
  /// **'Educativo'**
  String get genreEducational;

  /// No description provided for @genreThriller.
  ///
  /// In pt, this message translates to:
  /// **'Suspense'**
  String get genreThriller;

  /// No description provided for @genreBiography.
  ///
  /// In pt, this message translates to:
  /// **'Biografia'**
  String get genreBiography;

  /// No description provided for @genreFiction.
  ///
  /// In pt, this message translates to:
  /// **'Ficção'**
  String get genreFiction;

  /// No description provided for @genreHistory.
  ///
  /// In pt, this message translates to:
  /// **'História'**
  String get genreHistory;

  /// No description provided for @genreSelfHelp.
  ///
  /// In pt, this message translates to:
  /// **'Autoajuda'**
  String get genreSelfHelp;

  /// No description provided for @genreFantasy.
  ///
  /// In pt, this message translates to:
  /// **'Fantasia'**
  String get genreFantasy;

  /// No description provided for @genreHorror.
  ///
  /// In pt, this message translates to:
  /// **'Terror'**
  String get genreHorror;

  /// No description provided for @genrePoetry.
  ///
  /// In pt, this message translates to:
  /// **'Poesia'**
  String get genrePoetry;

  /// No description provided for @genreScienceTechnology.
  ///
  /// In pt, this message translates to:
  /// **'Ciência e Tecnologia'**
  String get genreScienceTechnology;

  /// No description provided for @genreChildrenAndTeens.
  ///
  /// In pt, this message translates to:
  /// **'Infantojuvenil'**
  String get genreChildrenAndTeens;

  /// No description provided for @categoryEmptyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum livro encontrado'**
  String get categoryEmptyTitle;

  /// No description provided for @categoryEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não há livros cadastrados em \"{category}\".\nVolte em breve para novas adições!'**
  String categoryEmptyMessage(String category);

  /// No description provided for @categoryExploreOthers.
  ///
  /// In pt, this message translates to:
  /// **'EXPLORAR OUTROS'**
  String get categoryExploreOthers;

  /// No description provided for @bookDetailsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes'**
  String get bookDetailsTitle;

  /// No description provided for @bookCoverMissing.
  ///
  /// In pt, this message translates to:
  /// **'Sem Capa'**
  String get bookCoverMissing;

  /// No description provided for @bookReleasedOn.
  ///
  /// In pt, this message translates to:
  /// **'Lançado em {date}'**
  String bookReleasedOn(String date);

  /// No description provided for @bookRatingsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Avaliações'**
  String get bookRatingsLabel;

  /// No description provided for @bookCoverTypeLabel.
  ///
  /// In pt, this message translates to:
  /// **'Tipo da Capa'**
  String get bookCoverTypeLabel;

  /// No description provided for @bookAgeRatingLabel.
  ///
  /// In pt, this message translates to:
  /// **'Faixa Etária'**
  String get bookAgeRatingLabel;

  /// No description provided for @bookPublisherLabel.
  ///
  /// In pt, this message translates to:
  /// **'Editora'**
  String get bookPublisherLabel;

  /// No description provided for @bookGenresLabel.
  ///
  /// In pt, this message translates to:
  /// **'Gêneros'**
  String get bookGenresLabel;

  /// No description provided for @bookSynopsisLabel.
  ///
  /// In pt, this message translates to:
  /// **'Sinopse'**
  String get bookSynopsisLabel;

  /// No description provided for @loanButtonGuest.
  ///
  /// In pt, this message translates to:
  /// **'FAÇA LOGIN PARA SOLICITAR'**
  String get loanButtonGuest;

  /// No description provided for @loanButtonNoCopies.
  ///
  /// In pt, this message translates to:
  /// **'SEM EXEMPLARES CADASTRADOS'**
  String get loanButtonNoCopies;

  /// No description provided for @loanButtonLimitReached.
  ///
  /// In pt, this message translates to:
  /// **'LIMITE DE EMPRÉSTIMOS ATINGIDO'**
  String get loanButtonLimitReached;

  /// No description provided for @loanButtonRequest.
  ///
  /// In pt, this message translates to:
  /// **'SOLICITAR EMPRÉSTIMO'**
  String get loanButtonRequest;

  /// No description provided for @loanButtonPending.
  ///
  /// In pt, this message translates to:
  /// **'AGUARDANDO APROVAÇÃO'**
  String get loanButtonPending;

  /// No description provided for @loanButtonActiveUntil.
  ///
  /// In pt, this message translates to:
  /// **'EM USO ATÉ: {date}'**
  String loanButtonActiveUntil(String date);

  /// No description provided for @loanButtonOverdue.
  ///
  /// In pt, this message translates to:
  /// **'DEVOLUÇÃO EXCEDIDA'**
  String get loanButtonOverdue;

  /// No description provided for @loanButtonAvailableFrom.
  ///
  /// In pt, this message translates to:
  /// **'DISPONÍVEL A PARTIR DE: {date}'**
  String loanButtonAvailableFrom(String date);

  /// No description provided for @loanButtonUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'INDISPONÍVEL NO MOMENTO'**
  String get loanButtonUnavailable;

  /// No description provided for @loansTabInProgress.
  ///
  /// In pt, this message translates to:
  /// **'Em Andamento'**
  String get loansTabInProgress;

  /// No description provided for @loansTabHistory.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get loansTabHistory;

  /// No description provided for @loansHistoryEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum histórico encontrado.'**
  String get loansHistoryEmpty;

  /// No description provided for @loansActiveEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum empréstimo ou solicitação ativa.'**
  String get loansActiveEmpty;

  /// No description provided for @loanStatusRejected.
  ///
  /// In pt, this message translates to:
  /// **'Solicitação Recusada'**
  String get loanStatusRejected;

  /// No description provided for @loanStatusPending.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando Aprovação'**
  String get loanStatusPending;

  /// No description provided for @loanStatusReturned.
  ///
  /// In pt, this message translates to:
  /// **'Devolvido'**
  String get loanStatusReturned;

  /// No description provided for @loanStatusOverdue.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Atrasado (1 dia)} other{Atrasado ({count} dias)}}'**
  String loanStatusOverdue(int count);

  /// No description provided for @loanStatusDueToday.
  ///
  /// In pt, this message translates to:
  /// **'Vence Hoje!'**
  String get loanStatusDueToday;

  /// No description provided for @loanStatusDueInDays.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{Devolve em 1 dia} other{Devolve em {count} dias}}'**
  String loanStatusDueInDays(int count);

  /// No description provided for @loanRequestedOn.
  ///
  /// In pt, this message translates to:
  /// **'Solicitado em: {date}'**
  String loanRequestedOn(String date);

  /// No description provided for @loanBorrowedOn.
  ///
  /// In pt, this message translates to:
  /// **'Emprestado em: {date}'**
  String loanBorrowedOn(String date);

  /// No description provided for @likesEmptyMessage.
  ///
  /// In pt, this message translates to:
  /// **'Você ainda não curtiu nenhum livro.'**
  String get likesEmptyMessage;

  /// No description provided for @profileSubtitleWithRank.
  ///
  /// In pt, this message translates to:
  /// **'{registration} - Ranking: {rank}'**
  String profileSubtitleWithRank(String registration, String rank);

  /// No description provided for @offlineBannerMessage.
  ///
  /// In pt, this message translates to:
  /// **'Você está offline. Exibindo dados salvos.'**
  String get offlineBannerMessage;

  /// No description provided for @apiHealthWakingBanner.
  ///
  /// In pt, this message translates to:
  /// **'Servidor acordando… {elapsed}'**
  String apiHealthWakingBanner(String elapsed);

  /// No description provided for @apiHealthWakingToast.
  ///
  /// In pt, this message translates to:
  /// **'O servidor estava em repouso e está iniciando. Pode levar até 3 minutos: o app tenta sozinho e carrega o conteúdo assim que ele responder.'**
  String get apiHealthWakingToast;

  /// No description provided for @apiHealthRestoredToast.
  ///
  /// In pt, this message translates to:
  /// **'Servidor no ar. Carregando o conteúdo.'**
  String get apiHealthRestoredToast;

  /// No description provided for @apiHealthUnreachableBanner.
  ///
  /// In pt, this message translates to:
  /// **'Servidor sem resposta. Toque para tentar de novo.'**
  String get apiHealthUnreachableBanner;

  /// No description provided for @likeAction.
  ///
  /// In pt, this message translates to:
  /// **'Curtir'**
  String get likeAction;

  /// No description provided for @unlikeAction.
  ///
  /// In pt, this message translates to:
  /// **'Remover dos curtidos'**
  String get unlikeAction;

  /// No description provided for @interestOfflineError.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão: a curtida não foi salva.'**
  String get interestOfflineError;

  /// No description provided for @interestSaveError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a curtida. Tente de novo.'**
  String get interestSaveError;

  /// No description provided for @interestMigratedNotice.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 livro curtido neste aparelho foi salvo na sua conta.} other{{count} livros curtidos neste aparelho foram salvos na sua conta.}}'**
  String interestMigratedNotice(int count);
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
      <String>['en', 'es', 'hi', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'hi':
      return AppLocalizationsHi();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
