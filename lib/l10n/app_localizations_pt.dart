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
  String get biometricEnablePrompt =>
      'Confirme sua identidade para ativar o acesso com biometria.';

  @override
  String get biometricUnlockPrompt =>
      'Confirme sua identidade para continuar no LumiLivre.';

  @override
  String get biometricEnableFailed =>
      'Não foi possível confirmar sua identidade. A biometria continua desligada.';

  @override
  String get biometricEnabledConfirmation =>
      'Biometria ativada. Ela será pedida na próxima abertura do app.';

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
  String get guestName => 'Convidado';

  @override
  String get guestAccessDisabled =>
      'O acesso de convidado está desativado nesta biblioteca.';

  @override
  String get retryAction => 'Tentar novamente';

  @override
  String get sessionExpiredMessage =>
      'Sua sessão expirou. Entre novamente para continuar.';

  @override
  String get bookDetailsLoadError =>
      'Não foi possível carregar os detalhes do livro.';

  @override
  String get guestBookTitle => 'Faça login para ver este livro';

  @override
  String get guestBookMessage =>
      'A ficha completa, a disponibilidade e o empréstimo são para leitores da biblioteca.';

  @override
  String get profileTabLoans => 'Empréstimos';

  @override
  String get profileTabLikes => 'Curtidos';

  @override
  String get profileTabRanking => 'Ranking';

  @override
  String get guestLoansTitle => 'Faça login para ver seus empréstimos';

  @override
  String get guestLoansMessage =>
      'Acompanhe seus empréstimos ativos e o histórico.';

  @override
  String get guestLikesTitle => 'Faça login para curtir livros';

  @override
  String get guestLikesMessage =>
      'Salve seus livros favoritos para acompanhar depois.';

  @override
  String get guestRankingTitle => 'Faça login para ver o ranking';

  @override
  String get guestRankingMessage =>
      'Compare suas leituras no ranking de leitores.';

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

  @override
  String get muralTitle => 'Mural';

  @override
  String get muralEmpty => 'Nenhuma publicação por aqui ainda.';

  @override
  String get muralError =>
      'Não foi possível carregar o mural. Verifique sua conexão.';

  @override
  String get muralRetry => 'Tentar novamente';

  @override
  String get muralLoginPrompt => 'Faça login para ver o mural.';

  @override
  String get muralTypeAnnouncement => 'Comunicado';

  @override
  String get muralTypeAttachment => 'Anexo';

  @override
  String get muralTypeWork => 'Trabalho';

  @override
  String get muralOpenDocument => 'Abrir documento';

  @override
  String get muralExternalLink => 'Link externo';

  @override
  String muralByAuthors(String authors) {
    return 'por $authors';
  }

  @override
  String get muralAuthorsLabel => 'Autor(es)';

  @override
  String get muralAdvisorsLabel => 'Orientador(es)';

  @override
  String get muralYearLabel => 'Ano';

  @override
  String get muralSemesterLabel => 'Semestre';

  @override
  String get forceUpdateTitle => 'Atualize o aplicativo';

  @override
  String get forceUpdateMessage =>
      'Uma nova versão obrigatória está disponível. Atualize para continuar usando o LumiLivre.';

  @override
  String get forceUpdateButton => 'Atualizar agora';

  @override
  String get forceUpdateStoreError =>
      'Não foi possível abrir a loja de aplicativos.';

  @override
  String get tourSkip => 'Pular';

  @override
  String get tourNext => 'Próximo';

  @override
  String get tourFinish => 'Concluir';

  @override
  String get tourStep1Title => 'Bem-vindo(a) ao LumiLivre!';

  @override
  String get tourStep1Body =>
      'Descubra e acompanhe os livros da sua biblioteca em um só lugar.';

  @override
  String get tourStep2Title => 'Explore o acervo';

  @override
  String get tourStep2Body =>
      'Navegue pelo Catálogo ou filtre por Categorias para encontrar sua próxima leitura.';

  @override
  String get tourStep3Title => 'Busque e fique por dentro';

  @override
  String get tourStep3Body =>
      'Use a busca para achar títulos rapidamente e confira o Mural para novidades e comunicados.';

  @override
  String get tourStep4Title => 'Seu espaço';

  @override
  String get tourStep4Body =>
      'No Perfil você acompanha empréstimos, troca sua foto e ajusta suas preferências.';
}
