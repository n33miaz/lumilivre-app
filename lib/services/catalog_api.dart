import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';

class CatalogApi {
  static const String _catalogCacheKey = 'catalog_cache_v1';
  final AuthStorage _authStorage = AuthStorage();

  Future<Map<String, List<Book>>?> getCatalogLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_catalogCacheKey);

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
    final url = Uri.parse('$apiBaseUrl/livros/catalogo-mobile');
    final prefs = await SharedPreferences.getInstance();
    final token = await _authStorage.getToken();

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
      if (kDebugMode) debugPrint('Erro na requisição do catálogo: $e');
      rethrow;
    }
  }

  Future<List<Book>> searchBooks(String query, {int page = 0}) async {
    final url = Uri.parse(
      '$apiBaseUrl/livros/mobile/buscar?texto=${Uri.encodeComponent(query)}&page=$page&size=20',
    );
    final token = await _authStorage.getToken();

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
      if (kDebugMode) debugPrint('Erro em searchBooks: $e');
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }

  Future<List<Book>> getBooksByGenre(String genre, {int page = 0}) async {
    final url = Uri.parse(
      '$apiBaseUrl/livros/genero/${Uri.encodeComponent(genre)}?page=$page&size=10',
    );
    final token = await _authStorage.getToken();

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
            imageUrl: bookData['imagem'] ?? 'https://via.placeholder.com/140x210.png?text=Lumi',
            rating: (bookData['avaliacao'] as num?)?.toDouble() ?? 4.6,
          );
        }).toList();
      } else if (response.statusCode == 204) {
        return [];
      } else {
        throw Exception('Falha ao carregar livros do gênero: $genre');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Erro em getBooksByGenre: $e');
      throw Exception('Não foi possível conectar ao servidor.');
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

      if (books.isNotEmpty) catalog[genreName] = books;
    }
    return catalog;
  }
}
