import 'package:flutter/foundation.dart';

import '../models/book.dart';
import '../models/book_details.dart';
import '../models/loan.dart';
import '../models/ranking.dart';
import '../models/user.dart';

import 'auth_api.dart';
import 'book_api.dart';
import 'catalog_api.dart';
import 'loan_api.dart';
import 'ranking_api.dart';
import 'student_api.dart';
import 'upload_api.dart';

export 'auth_api.dart';
export 'book_api.dart';
export 'catalog_api.dart';
export 'loan_api.dart';
export 'ranking_api.dart';
export 'student_api.dart';
export 'upload_api.dart';

/// Facade that preserves the original ApiService public interface.
/// All methods delegate to domain-specific API classes.
class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  final AuthApi _auth = AuthApi();
  final CatalogApi _catalog = CatalogApi();
  final BookApi _book = BookApi();
  final LoanApi _loan = LoanApi();
  final StudentApi _student = StudentApi();
  final RankingApi _ranking = RankingApi();
  final UploadApi _upload = UploadApi();

  // --- Auth ---

  Future<LoginResponse> login(String user, String password) =>
      _auth.login(user, password);

  Future<bool> changePassword(
    String matricula,
    String currentPassword,
    String newPassword,
    String token,
  ) => _auth.changePassword(matricula, currentPassword, newPassword, token);

  // --- Catalog ---

  Future<Map<String, List<Book>>?> getCatalogLocal() =>
      _catalog.getCatalogLocal();

  Future<Map<String, List<Book>>> fetchAndSaveCatalog() =>
      _catalog.fetchAndSaveCatalog();

  Future<List<Book>> searchBooks(String query, {int page = 0}) =>
      _catalog.searchBooks(query, page: page);

  Future<List<Book>> getBooksByGenre(String genre, {int page = 0}) =>
      _catalog.getBooksByGenre(genre, page: page);

  // --- Books ---

  Future<BookDetails> getBookDetails(int bookId) =>
      _book.getBookDetails(bookId);

  // --- Loans ---

  Future<List<Loan>> getMyLoans(String matricula, String token) =>
      _loan.getMyLoans(matricula, token);

  Future<List<Loan>> getMyRequests(String matricula, String token) =>
      _loan.getMyRequests(matricula, token);

  Future<bool> requestLoan(String matricula, String tombo, String token) =>
      _loan.requestLoan(matricula, tombo, token);

  Future<bool> requestLoanByBookId(
    String matricula,
    int livroId,
    String token,
  ) => _loan.requestLoanByBookId(matricula, livroId, token);

  Future<List<Loan>> getMyLoansHistory(String matricula, String token) =>
      _loan.getMyLoansHistory(matricula, token);

  // --- Students ---

  Future<String?> getStudentName(String matricula, String token) =>
      _student.getStudentName(matricula, token);

  Future<Map<String, dynamic>?> getStudentData(
    String matricula,
    String token,
  ) => _student.getStudentData(matricula, token);

  // --- Ranking ---

  Future<List<RankingItem>> getRanking({
    int top = 50,
    int? cursoId,
    int? moduloId,
    int? turnoId,
    required String token,
  }) => _ranking.getRanking(
    top: top,
    cursoId: cursoId,
    moduloId: moduloId,
    turnoId: turnoId,
    token: token,
  );

  Future<List<FilterItem>> getSimpleList(String endpoint, String token) =>
      _ranking.getSimpleList(endpoint, token);

  Future<List<FilterItem>> getCursos(String token) => _ranking.getCursos(token);

  // --- Upload ---

  Future<bool> uploadProfilePicture(
    String matricula,
    String token,
    String filePath, {
    Uint8List? webBytes,
  }) => _upload.uploadProfilePicture(
    matricula,
    token,
    filePath,
    webBytes: webBytes,
  );
}
