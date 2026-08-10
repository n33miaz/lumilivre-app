// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'LumiLivre';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get languageSection => 'Idioma';

  @override
  String get securitySection => 'Seguridad';

  @override
  String get accountSection => 'Cuenta';

  @override
  String get themeLabel => 'Tema';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get languagePortuguese => 'Portugués (Brasil)';

  @override
  String get languageEnglish => 'Inglés (EE. UU.)';

  @override
  String get languageSpanish => 'Español (España)';

  @override
  String get languageChinese => 'Chino (simplificado)';

  @override
  String get languageHindi => 'Hindi (India)';

  @override
  String get biometricAccess => 'Acceso con biometría';

  @override
  String get biometricSubtitle => 'Entra con huella o rostro.';

  @override
  String get biometricUnavailable =>
      'La biometría no está disponible en este dispositivo.';

  @override
  String get biometricEnablePrompt =>
      'Confirma tu identidad para activar el acceso con biometría.';

  @override
  String get biometricUnlockPrompt =>
      'Confirma tu identidad para continuar en LumiLivre.';

  @override
  String get biometricEnableFailed =>
      'No pudimos confirmar tu identidad. La biometría sigue desactivada.';

  @override
  String get biometricEnabledConfirmation =>
      'Biometría activada. Se te pedirá la próxima vez que abras la app.';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get logout => 'Salir de la cuenta';

  @override
  String get guestSettingsPrompt =>
      'Inicia sesión para acceder a toda la configuración';

  @override
  String get loginAction => 'Entrar';

  @override
  String get guestName => 'Invitado';

  @override
  String get guestAccessDisabled =>
      'El acceso de invitado está desactivado en esta biblioteca.';

  @override
  String get retryAction => 'Intentar de nuevo';

  @override
  String get sessionExpiredMessage =>
      'Tu sesión ha caducado. Entra de nuevo para continuar.';

  @override
  String get connectionErrorMessage =>
      'No pudimos contactar con el servidor. Verifica tu conexión e inténtalo de nuevo.';

  @override
  String get loginFailedMessage =>
      'No pudimos iniciar tu sesión. Revisa la matrícula y la contraseña.';

  @override
  String get linkOpenError => 'No se pudo abrir el enlace en este dispositivo.';

  @override
  String get offlineCachedDataMessage =>
      'Sin conexión: mostrando los datos guardados.';

  @override
  String get catalogRefreshError => 'No se pudo actualizar el catálogo.';

  @override
  String get bookListLoadError =>
      'No se pudieron cargar los libros. Verifica tu conexión.';

  @override
  String get loadMoreError => 'No se pudieron cargar más elementos.';

  @override
  String get searchError => 'No se pueden buscar libros en este momento.';

  @override
  String get passwordChangedMessage => 'Contraseña cambiada.';

  @override
  String get passwordChangeFailedMessage =>
      'No se pudo cambiar la contraseña. Inténtalo de nuevo.';

  @override
  String get passwordChangeRequiredMessage =>
      'Cambia tu contraseña inicial para usar esta función.';

  @override
  String get avatarUploading => 'Enviando foto...';

  @override
  String get avatarUploadSuccess => 'Foto actualizada.';

  @override
  String get avatarUploadError => 'No se pudo actualizar la foto.';

  @override
  String get loanRequestSent =>
      'Solicitud enviada. Espera la aprobación de la biblioteca.';

  @override
  String get loanRequestFailed =>
      'No se puede solicitar este libro en este momento.';

  @override
  String get penaltyNoticeTitle => 'Préstamos pausados por ahora';

  @override
  String penaltyNoticeUntil(String date) {
    return 'Podrás volver a solicitar libros el $date.';
  }

  @override
  String penaltyNoticeKind(String kind) {
    return 'Registrado como: $kind';
  }

  @override
  String get penaltyNoticeHint =>
      'Hasta entonces puedes seguir explorando el catálogo y marcando libros como favoritos. Si tienes alguna duda, habla con la biblioteca.';

  @override
  String get bookDetailsLoadError =>
      'No se pudieron cargar los detalles del libro.';

  @override
  String get guestBookTitle => 'Inicia sesión para ver este libro';

  @override
  String get guestBookMessage =>
      'La ficha completa, la disponibilidad y el préstamo son para lectores de la biblioteca.';

  @override
  String get profileTabLoans => 'Préstamos';

  @override
  String get profileTabLikes => 'Favoritos';

  @override
  String get profileTabRanking => 'Clasificación';

  @override
  String get guestLoansTitle => 'Inicia sesión para ver tus préstamos';

  @override
  String get guestLoansMessage => 'Sigue tus préstamos activos y tu historial.';

  @override
  String get guestLikesTitle =>
      'Inicia sesión para marcar libros como favoritos';

  @override
  String get guestLikesMessage =>
      'Guarda tus libros favoritos para verlos después.';

  @override
  String get guestRankingTitle => 'Inicia sesión para ver la clasificación';

  @override
  String get guestRankingMessage =>
      'Compara tus lecturas en la clasificación de lectores.';

  @override
  String get readerTerm => 'Lector';

  @override
  String get filterRanking => 'Filtrar clasificación';

  @override
  String get courseLabel => 'Curso';

  @override
  String get moduleLabel => 'Módulo';

  @override
  String get shiftLabel => 'Turno';

  @override
  String get applyFilters => 'APLICAR FILTROS';

  @override
  String get clearFilters => 'Limpiar filtros';

  @override
  String get emptyRankingMessage => 'No se encontró ningún lector.';

  @override
  String get rankingLoginPrompt => 'Inicia sesión para ver la clasificación.';

  @override
  String get rankingUnavailable =>
      'Clasificación no disponible para esta biblioteca.';

  @override
  String get muralTitle => 'Tablón';

  @override
  String get muralEmpty => 'Todavía no hay publicaciones por aquí.';

  @override
  String get muralError => 'No se pudo cargar el tablón. Verifica tu conexión.';

  @override
  String get muralRetry => 'Intentar de nuevo';

  @override
  String get muralLoginPrompt => 'Inicia sesión para ver el tablón.';

  @override
  String get muralTypeAnnouncement => 'Comunicado';

  @override
  String get muralTypeAttachment => 'Adjunto';

  @override
  String get muralTypeWork => 'Trabajo';

  @override
  String get muralOpenDocument => 'Abrir documento';

  @override
  String get muralExternalLink => 'Enlace externo';

  @override
  String muralByAuthors(String authors) {
    return 'por $authors';
  }

  @override
  String get muralAuthorsLabel => 'Autor(es)';

  @override
  String get muralAdvisorsLabel => 'Tutor(es)';

  @override
  String get muralYearLabel => 'Año';

  @override
  String get muralSemesterLabel => 'Semestre';

  @override
  String muralUnseenCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count publicaciones nuevas',
      one: '1 publicación nueva',
    );
    return '$_temp0';
  }

  @override
  String get forceUpdateTitle => 'Actualiza la aplicación';

  @override
  String get forceUpdateMessage =>
      'Hay una nueva versión obligatoria disponible. Actualiza para seguir usando LumiLivre.';

  @override
  String get forceUpdateButton => 'Actualizar ahora';

  @override
  String get forceUpdateStoreError =>
      'No se pudo abrir la tienda de aplicaciones.';

  @override
  String get tourSkip => 'Omitir';

  @override
  String get tourNext => 'Siguiente';

  @override
  String get tourFinish => 'Finalizar';

  @override
  String get tourStep1Title => '¡Bienvenido(a) a LumiLivre!';

  @override
  String get tourStep1Body =>
      'Descubre y sigue los libros de tu biblioteca en un solo lugar.';

  @override
  String get tourStep2Title => 'Explora la colección';

  @override
  String get tourStep2Body =>
      'Navega por el Catálogo o filtra por Categorías para encontrar tu próxima lectura.';

  @override
  String get tourStep3Title => 'Busca y mantente al día';

  @override
  String get tourStep3Body =>
      'Usa la búsqueda para encontrar títulos rápidamente y consulta el Tablón para ver novedades y comunicados.';

  @override
  String get tourStep4Title => 'Tu espacio';

  @override
  String get tourStep4Body =>
      'En el Perfil sigues tus préstamos, cambias tu foto y ajustas tus preferencias.';

  @override
  String get cancelAction => 'CANCELAR';

  @override
  String get saveAction => 'GUARDAR';

  @override
  String get refreshAction => 'Actualizar';

  @override
  String get logoSemanticLabel => 'Logotipo de LumiLivre';

  @override
  String get loginSubmit => 'ENTRAR';

  @override
  String get loginAsGuest => 'ENTRAR COMO INVITADO';

  @override
  String get loginUserFieldLabel => 'Matrícula o correo electrónico';

  @override
  String get loginUserFieldRequired => 'Escribe tu usuario';

  @override
  String get loginPasswordRequired => 'Escribe tu contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get changePasswordTitle => 'Cambiar contraseña';

  @override
  String get mandatoryPasswordTitle => 'Cambiar la primera contraseña';

  @override
  String get mandatoryPasswordMessage =>
      'Por tu seguridad, cambia tu contraseña actual de acceso antes de continuar.';

  @override
  String get currentPasswordLabel => 'Contraseña actual';

  @override
  String get currentPasswordRequired => 'Indica la contraseña actual';

  @override
  String get newPasswordLabel => 'Nueva contraseña';

  @override
  String get newPasswordRequired => 'Indica la nueva contraseña';

  @override
  String get confirmNewPasswordLabel => 'Confirmar nueva contraseña';

  @override
  String get passwordsDoNotMatch => 'Las contraseñas no coinciden';

  @override
  String passwordMinLength(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mínimo $count caracteres',
      one: 'Mínimo 1 carácter',
    );
    return '$_temp0';
  }

  @override
  String get awaitingPasswordChange => 'Esperando el cambio de contraseña...';

  @override
  String get navCategories => 'Categorías';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navProfile => 'Perfil';

  @override
  String get searchHint => 'Busca un libro o autor';

  @override
  String searchResultsTitle(String query) {
    return 'Resultados de \"$query\"';
  }

  @override
  String get searchNoResults => 'No se encontró ningún libro.';

  @override
  String get browseAllTitle => 'Explora todas';

  @override
  String get genreThesis => 'Trabajos finales';

  @override
  String get genreAdventure => 'Aventura';

  @override
  String get genreRomance => 'Romance';

  @override
  String get genreEducational => 'Educativo';

  @override
  String get genreThriller => 'Suspense';

  @override
  String get genreBiography => 'Biografía';

  @override
  String get genreFiction => 'Ficción';

  @override
  String get genreHistory => 'Historia';

  @override
  String get genreSelfHelp => 'Autoayuda';

  @override
  String get genreFantasy => 'Fantasía';

  @override
  String get genreHorror => 'Terror';

  @override
  String get genrePoetry => 'Poesía';

  @override
  String get genreScienceTechnology => 'Ciencia y Tecnología';

  @override
  String get genreChildrenAndTeens => 'Infantil y juvenil';

  @override
  String get categoryEmptyTitle => 'No se encontró ningún libro';

  @override
  String categoryEmptyMessage(String category) {
    return 'Todavía no hay libros registrados en \"$category\".\n¡Vuelve pronto para ver las novedades!';
  }

  @override
  String get categoryExploreOthers => 'EXPLORAR OTRAS';

  @override
  String get bookDetailsTitle => 'Detalles';

  @override
  String get bookCoverMissing => 'Sin portada';

  @override
  String bookReleasedOn(String date) {
    return 'Publicado el $date';
  }

  @override
  String get bookRatingsLabel => 'Valoraciones';

  @override
  String get bookCoverTypeLabel => 'Tipo de portada';

  @override
  String get bookAgeRatingLabel => 'Edad recomendada';

  @override
  String get bookPublisherLabel => 'Editorial';

  @override
  String get bookGenresLabel => 'Géneros';

  @override
  String get bookSynopsisLabel => 'Sinopsis';

  @override
  String get loanButtonGuest => 'INICIA SESIÓN PARA SOLICITAR';

  @override
  String get loanButtonNoCopies => 'SIN EJEMPLARES REGISTRADOS';

  @override
  String get loanButtonLimitReached => 'LÍMITE DE PRÉSTAMOS ALCANZADO';

  @override
  String get loanButtonRequest => 'SOLICITAR PRÉSTAMO';

  @override
  String get loanButtonPending => 'ESPERANDO APROBACIÓN';

  @override
  String loanButtonActiveUntil(String date) {
    return 'EN USO HASTA: $date';
  }

  @override
  String get loanButtonOverdue => 'DEVOLUCIÓN VENCIDA';

  @override
  String loanButtonAvailableFrom(String date) {
    return 'DISPONIBLE A PARTIR DE: $date';
  }

  @override
  String get loanButtonUnavailable => 'NO DISPONIBLE AHORA';

  @override
  String get loansTabInProgress => 'En curso';

  @override
  String get loansTabHistory => 'Historial';

  @override
  String get loansHistoryEmpty => 'No se encontró historial.';

  @override
  String get loansActiveEmpty => 'No hay préstamos ni solicitudes activas.';

  @override
  String get loanStatusRejected => 'Solicitud rechazada';

  @override
  String get loanStatusPending => 'Esperando aprobación';

  @override
  String get loanStatusReturned => 'Devuelto';

  @override
  String loanStatusOverdue(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Atrasado ($count días)',
      one: 'Atrasado (1 día)',
    );
    return '$_temp0';
  }

  @override
  String get loanStatusDueToday => '¡Vence hoy!';

  @override
  String loanStatusDueInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se devuelve en $count días',
      one: 'Se devuelve en 1 día',
    );
    return '$_temp0';
  }

  @override
  String loanRequestedOn(String date) {
    return 'Solicitado el: $date';
  }

  @override
  String loanBorrowedOn(String date) {
    return 'Prestado el: $date';
  }

  @override
  String get likesEmptyMessage =>
      'Todavía no has marcado ningún libro como favorito.';

  @override
  String profileSubtitleWithRank(String registration, String rank) {
    return '$registration - Clasificación: $rank';
  }

  @override
  String get offlineBannerMessage =>
      'Estás sin conexión. Mostrando los datos guardados.';

  @override
  String apiHealthWakingBanner(String elapsed) {
    return 'Servidor despertando… $elapsed';
  }

  @override
  String get apiHealthWakingToast =>
      'El servidor estaba en reposo y está iniciándose. Puede tardar hasta 3 minutos: la app sigue intentándolo sola y carga el contenido en cuanto responda.';

  @override
  String get apiHealthRestoredToast =>
      'El servidor volvió. Cargando el contenido.';

  @override
  String get apiHealthUnreachableBanner =>
      'El servidor no responde. Toca para intentarlo de nuevo.';

  @override
  String get likeAction => 'Me gusta';

  @override
  String get unlikeAction => 'Quitar de me gusta';

  @override
  String get interestOfflineError => 'Sin conexión: no se guardó tu me gusta.';

  @override
  String get interestSaveError =>
      'No se pudo guardar tu me gusta. Inténtalo de nuevo.';

  @override
  String interestMigratedNotice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count libros marcados en este dispositivo se guardaron en tu cuenta.',
      one: '1 libro marcado en este dispositivo se guardó en tu cuenta.',
    );
    return '$_temp0';
  }
}
