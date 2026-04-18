import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/book_details.dart';
import '../services/auth_storage.dart';
import '../utils/constants.dart';

class BookApi {
  final AuthStorage _authStorage = AuthStorage();

  Future<BookDetails> getBookDetails(int bookId) async {
    final url = Uri.parse('$apiBaseUrl/livros/$bookId');
    final token = await _authStorage.getToken();

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
      if (kDebugMode) debugPrint('Erro em getBookDetails: $e');
      throw Exception('Falha ao carregar detalhes do livro.');
    }
  }
}
