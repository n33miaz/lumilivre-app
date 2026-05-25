import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/book_details.dart';
import '../utils/constants.dart';
import 'auth_storage.dart';
import 'request_context.dart';

class BookApi {
  final AuthStorage _authStorage = AuthStorage();

  Future<BookDetails> getBookDetails(String bookId) async {
    final url = Uri.parse('$apiBaseUrl/api/books/$bookId');
    final token = await _authStorage.getToken();

    try {
      final response = await http
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return BookDetails.fromJson(jsonData);
      }
      throw Exception('Falha ao carregar detalhes do livro.');
    } catch (e) {
      if (kDebugMode) debugPrint('Erro em getBookDetails: $e');
      throw Exception('Falha ao carregar detalhes do livro.');
    }
  }
}
