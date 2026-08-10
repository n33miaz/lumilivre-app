import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/book_details.dart';
import '../utils/constants.dart';
import 'api_error.dart';
import 'request_context.dart';

class BookApi {
  BookApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Ficha do livro. `GET /api/books/{id}` exige papel READER hoje: sem [token]
  /// a API responde 401 e o erro sai tipado como [ApiFailure.unauthorized] para
  /// a tela poder convidar ao login em vez de acusar falha de rede.
  ///
  /// O token vem de quem chama (e não do armazenamento seguro, como antes)
  /// porque a sessão só existe para a UI depois do gate biométrico: ler o token
  /// direto do storage fazia a requisição sair autenticada mesmo com o app em
  /// modo convidado.
  Future<BookDetails> getBookDetails(String bookId, {String? token}) async {
    final url = Uri.parse('$apiBaseUrl/api/books/$bookId');

    try {
      final response = await _client
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(ApiTimeouts.standard);

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return BookDetails.fromJson(jsonData);
      }
      throw ApiException.fromStatus(response.statusCode);
    } catch (e) {
      final failure = ApiException.fromError(e);
      if (kDebugMode) debugPrint('Erro em getBookDetails: $failure');
      throw failure;
    }
  }
}
