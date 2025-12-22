import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../utils/constants.dart';
import '../models/user.dart';
import '../models/book.dart';
import '../models/book_details.dart';
import '../models/loan.dart';
import '../models/ranking.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  static const String _catalogCacheKey = 'catalog_cache_v1';

  // --- MÉTODOS DE CACHE E CATÁLOGO ---

  Future<Map<String, List<Book>>?> getCatalogLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_catalogCacheKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> data = json.decode(jsonString);
        return _parseCatalogJson(data);
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao ler cache local: $e');
    }
    return null;
  }

  Future<Map<String, List<Book>>> fetchAndSaveCatalog() async {
    final url = Uri.parse('$apiBaseUrl/livros/catalogo-mobile');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      final response = await http
          .get(
            url,
            headers: token != null ? {'Authorization': 'Bearer $token'} : {},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final String body = utf8.decode(response.bodyBytes);

        if (body.isNotEmpty) {
          await prefs.setString(_catalogCacheKey, body);

          final List<dynamic> data = json.decode(body);
          return _parseCatalogJson(data);
        }
        return {};
      } else if (response.statusCode == 204) {
        return {};
      } else {
        throw Exception('Falha ao carregar o catálogo: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Erro na requisição do catálogo: $e');
      rethrow;
    }
  }

  Map<String, List<Book>> _parseCatalogJson(List<dynamic> data) {
    Map<String, List<Book>> catalog = {};

    for (var genreData in data) {
      if (genreData['nome'] == null || genreData['livros'] == null) continue;

      String genreName = genreData['nome'];

      List<Book> books = (genreData['livros'] as List).map((bookData) {
        String rawImage = bookData['imagem']?.toString() ?? '';
        String finalImage = '';
        if (rawImage.isNotEmpty) {
          finalImage = rawImage.startsWith('http://')
              ? rawImage.replaceFirst('http://', 'https://')
              : rawImage;
        }

        return Book(
          id: (bookData['id'] as num?)?.toInt() ?? 0,
          title: bookData['titulo']?.toString() ?? 'Título Desconhecido',
          author: bookData['autor']?.toString() ?? 'Autor Desconhecido',
          imageUrl: finalImage,
          rating: (bookData['avaliacao'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();

      if (books.isNotEmpty) {
        catalog[genreName] = books;
      }
    }
    return catalog;
  }

  // --- MÉTODOS DE AUTENTICAÇÃO ---

  Future<LoginResponse> login(String user, String password) async {
    final url = Uri.parse('$apiBaseUrl/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'user': user, 'senha': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loginResponseFromJson(response.body);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Falha no login');
      }
    } catch (e) {
      print('Erro na chamada de login: $e');
      throw Exception(
        'Não foi possível conectar ao servidor. Tente novamente.',
      );
    }
  }

  Future<bool> changePassword(
    String matricula,
    String currentPassword,
    String newPassword,
    String token,
  ) async {
    final url = Uri.parse('$apiBaseUrl/usuarios/alterar-senha');

    try {
      final response = await http
          .put(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'matricula': matricula,
              'senhaAtual': currentPassword,
              'novaSenha': newPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception(errorData['message'] ?? 'Erro ao alterar senha');
      }
    } catch (e) {
      print('Erro changePassword: $e');
      rethrow;
    }
  }

  // --- MÉTODOS DE LIVROS E BUSCA ---

  Future<List<Book>> searchBooks(String query, {int page = 0}) async {
    final url = Uri.parse(
      '$apiBaseUrl/livros/mobile/buscar?texto=${Uri.encodeComponent(query)}&page=$page&size=20',
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    try {
      final response = await http
          .get(
            url,
            headers: token != null ? {'Authorization': 'Bearer $token'} : {},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> pageData = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> bookList = pageData['content'];

        return bookList.map((bookData) {
          return Book(
            id: (bookData['id'] as num?)?.toInt() ?? 0,
            title: bookData['titulo'] ?? bookData['nome'] ?? 'Sem Título',
            author: bookData['autor'] ?? 'Autor desconhecido',
            imageUrl: bookData['imagem'] ?? '',
            rating: (bookData['avaliacao'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception('Erro na busca: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Erro em searchBooks: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  Future<BookDetails> getBookDetails(int bookId) async {
    final url = Uri.parse('$apiBaseUrl/livros/$bookId');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    try {
      final response = await http
          .get(
            url,
            headers: token != null ? {'Authorization': 'Bearer $token'} : {},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return BookDetails.fromJson(jsonData);
      } else {
        throw Exception('Falha ao carregar detalhes do livro.');
      }
    } catch (e) {
      if (kDebugMode) print('Erro em getBookDetails: $e');
      throw Exception('Falha ao carregar detalhes do livro.');
    }
  }

  Future<List<Book>> getBooksByGenre(String genre, {int page = 0}) async {
    final url = Uri.parse(
      '$apiBaseUrl/livros/genero/${Uri.encodeComponent(genre)}?page=$page&size=10',
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    try {
      final response = await http
          .get(
            url,
            headers: token != null ? {'Authorization': 'Bearer $token'} : {},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> pageData = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> bookList = pageData['content'];
        return bookList.map((bookData) {
          return Book(
            id: (bookData['id'] as num?)?.toInt() ?? 0,
            title: bookData['titulo'] ?? bookData['nome'] ?? 'Sem Título',
            author: bookData['autor'] ?? 'Autor desconhecido',
            imageUrl:
                bookData['imagem'] ??
                'https://via.placeholder.com/140x210.png?text=Lumi',
            rating: (bookData['avaliacao'] as num?)?.toDouble() ?? 4.6,
          );
        }).toList();
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception('Falha ao carregar livros do gênero: $genre');
      }
    } catch (e) {
      if (kDebugMode) print('Erro em getBooksByGenre: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  // --- MÉTODOS DE EMPRÉSTIMOS E SOLICITAÇÕES ---

  Future<List<Loan>> getMyLoans(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/emprestimos/aluno/$matricula');

    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loanFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw Exception(
          'Falha ao carregar empréstimos: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Erro em getMyLoans: $e');
      return [];
    }
  }

  Future<List<Loan>> getMyRequests(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/solicitacoes/aluno/$matricula');
    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((item) => Loan.fromRequestJson(item)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erro ao buscar solicitações: $e');
      return [];
    }
  }

  Future<bool> requestLoan(String matricula, String tombo, String token) async {
    final url = Uri.parse(
      '$apiBaseUrl/solicitacoes/solicitar?matriculaAluno=$matricula&tomboExemplar=$tombo',
    );

    try {
      final response = await http
          .post(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      print('Erro ao solicitar: $e');
      return false;
    }
  }

  Future<bool> requestLoanByBookId(
    String matricula,
    int livroId,
    String token,
  ) async {
    final url = Uri.parse(
      '$apiBaseUrl/solicitacoes/solicitar-mobile?matriculaAluno=$matricula&livroId=$livroId',
    );

    try {
      final response = await http
          .post(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Erro ao solicitar: $e');
      return false;
    }
  }

  Future<List<Loan>> getMyLoansHistory(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/emprestimos/aluno/$matricula/historico');

    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return loanFromJson(utf8.decode(response.bodyBytes));
      } else {
        throw Exception('Falha ao carregar histórico: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro em getMyLoansHistory: $e');
      return [];
    }
  }

  // --- MÉTODOS DE ALUNO E RANKING ---

  Future<String?> getStudentName(String matricula, String token) async {
    final url = Uri.parse('$apiBaseUrl/alunos/$matricula');
    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data']['nomeCompleto'];
        }
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar nome do aluno: $e');
    }
    return null;
  }

  Future<List<RankingItem>> getRanking({
    int top = 50,
    int? cursoId,
    int? moduloId,
    int? turnoId,
    required String token,
  }) async {
    String query = '?top=$top';
    if (cursoId != null) query += '&cursoId=$cursoId';
    if (moduloId != null) query += '&moduloId=$moduloId';
    if (turnoId != null) query += '&turnoId=$turnoId';

    final url = Uri.parse('$apiBaseUrl/emprestimos/ranking$query');

    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => RankingItem.fromJson(e)).toList();
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception('Erro ao buscar ranking');
      }
    } catch (e) {
      print('Erro getRanking: $e');
      return [];
    }
  }

  Future<List<FilterItem>> getSimpleList(String endpoint, String token) async {
    final url = Uri.parse('$apiBaseUrl/$endpoint');
    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => FilterItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar $endpoint: $e');
      return [];
    }
  }

  Future<List<FilterItem>> getCursos(String token) async {
    final url = Uri.parse('$apiBaseUrl/cursos/home?size=100');
    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> content = data['content'];
        return content.map((e) => FilterItem.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Erro ao buscar cursos: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getStudentData(
    String matricula,
    String token,
  ) async {
    final url = Uri.parse('$apiBaseUrl/alunos/$matricula');
    try {
      final response = await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(
          utf8.decode(response.bodyBytes),
        );
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          return jsonResponse['data'];
        }
      }
    } catch (e) {
      if (kDebugMode) print('Erro ao buscar dados do aluno: $e');
    }
    return null;
  }

  Future<bool> uploadProfilePicture(
    String matricula,
    String token,
    String filePath, {
    Uint8List? webBytes,
  }) async {
    final url = Uri.parse('$apiBaseUrl/alunos/$matricula/foto');
    final request = http.MultipartRequest('POST', url);

    request.headers['Authorization'] = 'Bearer $token';

    if (kIsWeb && webBytes != null) {
      // Web
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          webBytes,
          filename: 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      // Mobile 
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      ); 
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Erro upload: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Erro ao enviar foto: $e');
      return false;
    }
  }
}
