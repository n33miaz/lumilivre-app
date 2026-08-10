import 'package:flutter/foundation.dart';

import '../models/app_content.dart';
import '../models/app_version_info.dart';
import '../models/book.dart';
import '../models/book_details.dart';
import '../models/library_settings.dart';
import '../models/loan.dart';
import '../models/paged_result.dart';
import '../models/ranking.dart';
import '../models/user.dart';

import 'api_error.dart';
import 'api_health.dart';
import 'app_version_api.dart';
import 'auth_api.dart';
import 'book_api.dart';
import 'catalog_api.dart';
import 'content_api.dart';
import 'loan_api.dart';
import 'reader_api.dart';
import 'ranking_api.dart';
import 'settings_api.dart';
import 'upload_api.dart';

export 'api_error.dart';
export 'api_health.dart';
export 'app_version_api.dart';
export 'auth_api.dart';
export 'book_api.dart';
export 'catalog_api.dart';
export 'content_api.dart';
export 'loan_api.dart';
export 'reader_api.dart';
export 'ranking_api.dart';
export 'settings_api.dart';
export 'upload_api.dart';

/// Facade that preserves the original ApiService public interface.
/// All methods delegate to domain-specific API classes.
class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  final AuthApi _auth = AuthApi();
  final AppVersionApi _appVersion = AppVersionApi();
  final CatalogApi _catalog = CatalogApi();
  final ContentApi _content = ContentApi();
  final BookApi _book = BookApi();
  final LoanApi _loan = LoanApi();
  final ReaderApi _reader = ReaderApi();
  final RankingApi _ranking = RankingApi();
  final SettingsApi _settings = SettingsApi();
  final UploadApi _upload = UploadApi();

  /// Espera o servidor acordar e refaz a chamada, uma vez.
  ///
  /// A instância da API hiberna: a primeira chamada depois do sono estoura o
  /// prazo e a tela mostrava erro definitivo para uma indisponibilidade que se
  /// resolve sozinha em minutos. Quem chamou continua pendurado no mesmo
  /// `Future` — vendo o mesmo carregamento que já veria, com a faixa de aviso
  /// explicando o motivo e contando o tempo — em vez de precisar sair e entrar
  /// no app para tentar de novo.
  ///
  /// **Só envolve leitura.** Refazer sozinho um `POST` de solicitação de
  /// empréstimo criaria duas solicitações, e refazer um login três minutos
  /// depois deixaria a pessoa olhando um botão girando por três minutos. Nesses
  /// o erro sobe na hora e a tela decide o que dizer; o aquecimento disparado no
  /// login é o que reduz a chance de eles caírem aqui.
  ///
  /// Quando não há monitor ligado (testes), [ApiHealth.waitUntilReachable]
  /// responde `false` na hora e este método vira o repasse do erro que sempre
  /// foi.
  Future<T> _whenServerWakes<T>(Future<T> Function() call) async {
    try {
      return await call();
    } catch (error) {
      // `classify` e não `fromError`: o erro já foi reportado ao monitor lá
      // embaixo, no `catch` do próprio serviço.
      if (ApiException.classify(error).failure != ApiFailure.network) {
        rethrow;
      }
      if (!await ApiHealth.instance.waitUntilReachable()) {
        rethrow;
      }
      return await call();
    }
  }

  // --- Auth ---

  Future<LoginResponse> login(String user, String password) =>
      _auth.login(user, password);

  Future<String?> changePassword(
    String matricula,
    String currentPassword,
    String newPassword,
    String token,
  ) => _auth.changePassword(matricula, currentPassword, newPassword, token);

  Future<bool> logout(String token) => _auth.logout(token);

  Future<bool> completeTour(String token) => _auth.completeTour(token);

  // --- App version ---

  Future<AppVersionInfo> getAppVersion({required String platform}) =>
      _appVersion.get(platform: platform);

  // --- Catalog ---

  Future<Map<String, List<Book>>?> getCatalogLocal() =>
      _catalog.getCatalogLocal();

  Future<Map<String, List<Book>>> fetchAndSaveCatalog({String? token}) =>
      _whenServerWakes(() => _catalog.fetchAndSaveCatalog(token: token));

  Future<PagedResult<Book>> searchBooks(
    String query, {
    int page = 0,
    String? token,
  }) => _whenServerWakes(
    () => _catalog.searchBooks(query, page: page, token: token),
  );

  Future<PagedResult<Book>> getBooksByGenre(
    String genre, {
    int page = 0,
    String? token,
  }) => _whenServerWakes(
    () => _catalog.getBooksByGenre(genre, page: page, token: token),
  );

  // --- Contents (Mural) ---

  Future<List<AppContent>> getContentFeedLocal() => _content.getFeedLocal();

  Future<List<AppContent>> fetchAndSaveContentFeed({required String token}) =>
      _whenServerWakes(() => _content.fetchAndSaveFeed(token: token));

  Future<void> clearContentFeedCache() => _content.clearFeedCache();

  // --- Books ---

  Future<BookDetails> getBookDetails(String bookId, {String? token}) =>
      _whenServerWakes(() => _book.getBookDetails(bookId, token: token));

  // --- Loans ---

  Future<List<Loan>> getMyLoans(
    String readerRegistrationNumber,
    String token,
  ) =>
      _whenServerWakes(() => _loan.getMyLoans(readerRegistrationNumber, token));

  Future<List<Loan>> getMyRequests(
    String readerRegistrationNumber,
    String token,
  ) => _whenServerWakes(
    () => _loan.getMyRequests(readerRegistrationNumber, token),
  );

  Future<bool> requestLoan(
    String readerRegistrationNumber,
    String tombo,
    String token,
  ) => _loan.requestLoan(readerRegistrationNumber, tombo, token);

  Future<void> requestLoanByBookId(
    String readerRegistrationNumber,
    String livroId,
    String token,
  ) => _loan.requestLoanByBookId(readerRegistrationNumber, livroId, token);

  Future<List<Loan>> getMyLoansHistory(
    String readerRegistrationNumber,
    String token,
  ) => _whenServerWakes(
    () => _loan.getMyLoansHistory(readerRegistrationNumber, token),
  );

  // --- Readers ---

  Future<String?> getReaderName(String registrationNumber, String token) =>
      _whenServerWakes(() => _reader.getReaderName(registrationNumber, token));

  Future<Map<String, dynamic>?> getReaderData(
    String registrationNumber,
    String token,
  ) => _whenServerWakes(() => _reader.getReaderData(registrationNumber, token));

  // --- Ranking ---

  Future<List<RankingItem>> getRanking({
    int top = 50,
    int? cursoId,
    int? moduloId,
    int? turnoId,
    required String token,
  }) => _whenServerWakes(
    () => _ranking.getRanking(
      top: top,
      cursoId: cursoId,
      moduloId: moduloId,
      turnoId: turnoId,
      token: token,
    ),
  );

  Future<List<FilterItem>> getSimpleList(String endpoint, String token) =>
      _whenServerWakes(() => _ranking.getSimpleList(endpoint, token));

  Future<List<FilterItem>> getCursos(String token) =>
      _whenServerWakes(() => _ranking.getCursos(token));

  // --- Settings ---

  Future<LibrarySettings> getSettings(String token) =>
      _whenServerWakes(() => _settings.getSettings(token));

  // --- Upload ---

  Future<bool> uploadProfilePicture(
    String readerRegistrationNumber,
    String token,
    String filePath, {
    Uint8List? webBytes,
  }) => _upload.uploadProfilePicture(
    readerRegistrationNumber,
    token,
    filePath,
    webBytes: webBytes,
  );
}
