import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';
import '../utils/constants.dart';
import 'auth_storage.dart';
import 'request_context.dart';

class CatalogApi {
  static const String _catalogCacheKeyPrefix = 'catalog_cache_v2_';
  final AuthStorage _authStorage = AuthStorage();

  Future<Map<String, List<Book>>?> getCatalogLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final locale = await RequestContext.currentLocaleTag();
      final jsonString = prefs.getString('$_catalogCacheKeyPrefix$locale');

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> data = json.decode(jsonString);
        return _parseCatalogJson(data);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro ao ler cache local: $e');
    }
    return null;
  }

  Future<Map<String, List<Book>>> fetchAndSaveCatalog() async {
    final url = Uri.parse('$apiBaseUrl/api/books/catalog');
    final prefs = await SharedPreferences.getInstance();
    final token = await _authStorage.getToken();
    final locale = await RequestContext.currentLocaleTag();

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        if (body.isNotEmpty) {
          await prefs.setString('$_catalogCacheKeyPrefix$locale', body);
          final List<dynamic> data = json.decode(body);
          return _parseCatalogJson(data);
        }
        return {};
      }
      if (response.statusCode == 204) {
        return {};
      }
      throw Exception('Falha ao carregar o catalogo: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) debugPrint('Erro na requisicao do catalogo: $e');
      rethrow;
    }
  }

  Future<List<Book>> searchBooks(String query, {int page = 0}) async {
    final url = Uri.parse(
      '$apiBaseUrl/api/books/public/search?q=${Uri.encodeComponent(query)}&page=$page&size=20',
    );
    final token = await _authStorage.getToken();

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final pageData = json.decode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        final bookList = pageData['content'] as List<dynamic>;
        return bookList
            .map((bookData) => Book.fromMap(bookData as Map<String, dynamic>))
            .toList();
      }
      if (response.statusCode == 204) {
        return [];
      }
      throw Exception('Erro na busca: ${response.statusCode}');
    } catch (e) {
      if (kDebugMode) debugPrint('Erro em searchBooks: $e');
      throw Exception('Nao foi possivel conectar ao servidor.');
    }
  }

  Future<List<Book>> getBooksByGenre(String genre, {int page = 0}) async {
    final url = Uri.parse(
      '$apiBaseUrl/api/books/genres/${Uri.encodeComponent(genre)}?page=$page&size=10',
    );
    final token = await _authStorage.getToken();

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final pageData = json.decode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
        final bookList = pageData['content'] as List<dynamic>;
        return bookList
            .map((bookData) => Book.fromMap(bookData as Map<String, dynamic>))
            .toList();
      }
      if (response.statusCode == 204) {
        return [];
      }
      throw Exception('Falha ao carregar livros do genero: $genre');
    } catch (e) {
      if (kDebugMode) debugPrint('Erro em getBooksByGenre: $e');
      throw Exception('Nao foi possivel conectar ao servidor.');
    }
  }

  Map<String, List<Book>> _parseCatalogJson(List<dynamic> data) {
    final catalog = <String, List<Book>>{};

    for (final genreData in data) {
      final map = genreData as Map<String, dynamic>;
      final genreName =
          map['genreName']?.toString() ?? map['nome']?.toString() ?? '';
      final rawBooks = (map['books'] ?? map['livros']) as List<dynamic>?;
      if (genreName.isEmpty || rawBooks == null) {
        continue;
      }

      final books = rawBooks
          .map((bookData) => Book.fromMap(bookData as Map<String, dynamic>))
          .toList();

      if (books.isNotEmpty) {
        catalog[genreName] = books;
      }
    }

    return catalog;
  }
}
