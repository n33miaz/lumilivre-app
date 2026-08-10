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
  String get languageSpanish => 'Espanhol (Espanha)';

  @override
  String get languageChinese => 'Chinês (simplificado)';

  @override
  String get languageHindi => 'Hindi (Índia)';

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
  String get connectionErrorMessage =>
      'Não foi possível falar com o servidor. Verifique sua conexão e tente de novo.';

  @override
  String get loginFailedMessage =>
      'Não foi possível entrar. Confira a matrícula e a senha.';

  @override
  String get linkOpenError => 'Não foi possível abrir o link neste aparelho.';

  @override
  String get offlineCachedDataMessage =>
      'Sem conexão: mostrando os dados salvos.';

  @override
  String get catalogRefreshError => 'Não foi possível atualizar o catálogo.';

  @override
  String get bookListLoadError =>
      'Não foi possível carregar os livros. Verifique sua conexão.';

  @override
  String get loadMoreError => 'Não foi possível carregar mais itens.';

  @override
  String get searchError => 'Não foi possível buscar livros agora.';

  @override
  String get passwordChangedMessage => 'Senha alterada.';

  @override
  String get passwordChangeFailedMessage =>
      'Não foi possível alterar a senha. Tente novamente.';

  @override
  String get passwordChangeRequiredMessage =>
      'Troque sua senha inicial para usar esta função.';

  @override
  String get avatarUploading => 'Enviando foto...';

  @override
  String get avatarUploadSuccess => 'Foto atualizada.';

  @override
  String get avatarUploadError => 'Não foi possível atualizar a foto.';

  @override
  String get loanRequestSent =>
      'Solicitação enviada. Aguarde a aprovação da biblioteca.';

  @override
  String get loanRequestFailed =>
      'Não foi possível solicitar este livro agora.';

  @override
  String get penaltyNoticeTitle => 'Empréstimos pausados por enquanto';

  @override
  String penaltyNoticeUntil(String date) {
    return 'Você volta a solicitar livros em $date.';
  }

  @override
  String penaltyNoticeKind(String kind) {
    return 'Registrado como: $kind';
  }

  @override
  String get penaltyNoticeHint =>
      'Até lá você continua explorando o catálogo e curtindo livros. Se tiver alguma dúvida, fale com a biblioteca.';

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
  String muralUnseenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicações novas',
      one: '1 publicação nova',
    );
    return '$_temp0';
  }

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

  @override
  String get cancelAction => 'CANCELAR';

  @override
  String get saveAction => 'SALVAR';

  @override
  String get refreshAction => 'Atualizar';

  @override
  String get logoSemanticLabel => 'Logo LumiLivre';

  @override
  String get loginSubmit => 'ENTRAR';

  @override
  String get loginAsGuest => 'ENTRAR COMO CONVIDADO';

  @override
  String get loginUserFieldLabel => 'Matrícula ou Email';

  @override
  String get loginUserFieldRequired => 'Digite seu usuário';

  @override
  String get loginPasswordRequired => 'Digite sua senha';

  @override
  String get forgotPassword => 'Esqueceu sua senha?';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get changePasswordTitle => 'Alterar Senha';

  @override
  String get mandatoryPasswordTitle => 'Alterar Primeira Senha';

  @override
  String get mandatoryPasswordMessage =>
      'Para sua segurança, altere sua senha atual de login antes de continuar.';

  @override
  String get currentPasswordLabel => 'Senha Atual';

  @override
  String get currentPasswordRequired => 'Informe a senha atual';

  @override
  String get newPasswordLabel => 'Nova Senha';

  @override
  String get newPasswordRequired => 'Informe a nova senha';

  @override
  String get confirmNewPasswordLabel => 'Confirmar Nova Senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não conferem';

  @override
  String passwordMinLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mínimo de $count caracteres',
      one: 'Mínimo de 1 caractere',
    );
    return '$_temp0';
  }

  @override
  String get awaitingPasswordChange => 'Aguardando alteração de senha...';

  @override
  String get navCategories => 'Categorias';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navProfile => 'Perfil';

  @override
  String get searchHint => 'Procure por um livro ou autor';

  @override
  String searchResultsTitle(String query) {
    return 'Resultados para \"$query\"';
  }

  @override
  String get searchNoResults => 'Nenhum livro encontrado.';

  @override
  String get browseAllTitle => 'Navegue por todos';

  @override
  String get genreThesis => 'TCCs';

  @override
  String get genreAdventure => 'Aventura';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreEducational => 'Educativo';

  @override
  String get genreThriller => 'Suspense';

  @override
  String get genreBiography => 'Biografia';

  @override
  String get genreFiction => 'Ficção';

  @override
  String get genreHistory => 'História';

  @override
  String get genreSelfHelp => 'Autoajuda';

  @override
  String get genreFantasy => 'Fantasia';

  @override
  String get genreHorror => 'Terror';

  @override
  String get genrePoetry => 'Poesia';

  @override
  String get genreScienceTechnology => 'Ciência e Tecnologia';

  @override
  String get genreChildrenAndTeens => 'Infantojuvenil';

  @override
  String get categoryEmptyTitle => 'Nenhum livro encontrado';

  @override
  String categoryEmptyMessage(String category) {
    return 'Ainda não há livros cadastrados em \"$category\".\nVolte em breve para novas adições!';
  }

  @override
  String get categoryExploreOthers => 'EXPLORAR OUTROS';

  @override
  String get bookDetailsTitle => 'Detalhes';

  @override
  String get bookCoverMissing => 'Sem Capa';

  @override
  String bookReleasedOn(String date) {
    return 'Lançado em $date';
  }

  @override
  String get bookRatingsLabel => 'Avaliações';

  @override
  String get bookCoverTypeLabel => 'Tipo da Capa';

  @override
  String get bookAgeRatingLabel => 'Faixa Etária';

  @override
  String get bookPublisherLabel => 'Editora';

  @override
  String get bookGenresLabel => 'Gêneros';

  @override
  String get bookSynopsisLabel => 'Sinopse';

  @override
  String get loanButtonGuest => 'FAÇA LOGIN PARA SOLICITAR';

  @override
  String get loanButtonNoCopies => 'SEM EXEMPLARES CADASTRADOS';

  @override
  String get loanButtonLimitReached => 'LIMITE DE EMPRÉSTIMOS ATINGIDO';

  @override
  String get loanButtonRequest => 'SOLICITAR EMPRÉSTIMO';

  @override
  String get loanButtonPending => 'AGUARDANDO APROVAÇÃO';

  @override
  String loanButtonActiveUntil(String date) {
    return 'EM USO ATÉ: $date';
  }

  @override
  String get loanButtonOverdue => 'DEVOLUÇÃO EXCEDIDA';

  @override
  String loanButtonAvailableFrom(String date) {
    return 'DISPONÍVEL A PARTIR DE: $date';
  }

  @override
  String get loanButtonUnavailable => 'INDISPONÍVEL NO MOMENTO';

  @override
  String get loansTabInProgress => 'Em Andamento';

  @override
  String get loansTabHistory => 'Histórico';

  @override
  String get loansHistoryEmpty => 'Nenhum histórico encontrado.';

  @override
  String get loansActiveEmpty => 'Nenhum empréstimo ou solicitação ativa.';

  @override
  String get loanStatusRejected => 'Solicitação Recusada';

  @override
  String get loanStatusPending => 'Aguardando Aprovação';

  @override
  String get loanStatusReturned => 'Devolvido';

  @override
  String loanStatusOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Atrasado ($count dias)',
      one: 'Atrasado (1 dia)',
    );
    return '$_temp0';
  }

  @override
  String get loanStatusDueToday => 'Vence Hoje!';

  @override
  String loanStatusDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Devolve em $count dias',
      one: 'Devolve em 1 dia',
    );
    return '$_temp0';
  }

  @override
  String loanRequestedOn(String date) {
    return 'Solicitado em: $date';
  }

  @override
  String loanBorrowedOn(String date) {
    return 'Emprestado em: $date';
  }

  @override
  String get likesEmptyMessage => 'Você ainda não curtiu nenhum livro.';

  @override
  String profileSubtitleWithRank(String registration, String rank) {
    return '$registration - Ranking: $rank';
  }

  @override
  String get offlineBannerMessage =>
      'Você está offline. Exibindo dados salvos.';

  @override
  String apiHealthWakingBanner(String elapsed) {
    return 'Servidor acordando… $elapsed';
  }

  @override
  String get apiHealthWakingToast =>
      'O servidor estava em repouso e está iniciando. Pode levar até 3 minutos: o app tenta sozinho e carrega o conteúdo assim que ele responder.';

  @override
  String get apiHealthRestoredToast => 'Servidor no ar. Carregando o conteúdo.';

  @override
  String get apiHealthUnreachableBanner =>
      'Servidor sem resposta. Toque para tentar de novo.';

  @override
  String get likeAction => 'Curtir';

  @override
  String get unlikeAction => 'Remover dos curtidos';

  @override
  String get interestOfflineError => 'Sem conexão: a curtida não foi salva.';

  @override
  String get interestSaveError =>
      'Não foi possível salvar a curtida. Tente de novo.';

  @override
  String interestMigratedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count livros curtidos neste aparelho foram salvos na sua conta.',
      one: '1 livro curtido neste aparelho foi salvo na sua conta.',
    );
    return '$_temp0';
  }
}
