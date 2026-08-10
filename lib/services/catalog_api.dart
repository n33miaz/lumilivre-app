import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';
import '../models/paged_result.dart';
import '../utils/constants.dart';
import 'api_error.dart';
import 'request_context.dart';

/// Rotas de vitrine do acervo: catálogo, busca pública e páginas por gênero.
///
/// **O token vem sempre de quem chama, nunca do armazenamento seguro.** As três
/// rotas são `permitAll()` na API, então o token não abre porta alguma aqui — ele
/// só identifica o acesso na auditoria (`X-Client` + `Authorization`, WS-07).
/// Mesmo assim ler o token direto do `flutter_secure_storage`, como este arquivo
/// fazia, era errado: o app em modo convidado mandava `Authorization` de uma
/// sessão que o gate biométrico havia **recusado**. A tela dizia "Convidado" e o
/// `access_log` registrava o leitor travado.
///
/// Quem sabe se existe sessão é o `AuthProvider` — ele só expõe o usuário depois
/// do gate — e é de lá que o token desce (`AuthProvider.sessionToken`).
class CatalogApi {
  CatalogApi({http.Client? client}) : _client = client ?? http.Client();

  static const String _catalogCacheKeyPrefix = 'catalog_cache_v2_';

  /// Ordenação explícita das páginas de gênero.
  ///
  /// A consulta da API (`BookRepository.findByGeneroAsCatalogoDTO`) não tem
  /// `ORDER BY`, e paginar consulta sem ordem estável é a forma mais fácil de uma
  /// lista infinita mentir: o banco não promete a mesma ordem entre duas
  /// requisições, então a página 1 pode repetir ou pular livro da página 0.
  /// `title` sozinho não é ordem total (o acervo tem títulos repetidos em
  /// volumes), daí o `id` como desempate. Os dois campos existem na entidade
  /// `Book`; a rota é JPQL, não query nativa, então o Spring aplica o `sort` sem
  /// concatenar texto na consulta.
  static const List<String> _stableGenreSort = <String>['title,asc', 'id,asc'];

  final http.Client _client;

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
      if (kDebugMode) {
        debugPrint('Erro ao ler cache local: $e');
      }
    }
    return null;
  }

  /// Catálogo completo (a vitrine), gravado no cache local para o próximo abrir.
  ///
  /// A API devolve no máximo **10 livros por gênero** (`rn <= 10` em
  /// `findCatalogoMobile`). O cache guarda exatamente isso e nada mais: é a
  /// primeira tela de cada esteira, nunca a lista do gênero. As páginas buscadas
  /// depois por [getBooksByGenre] não voltam para cá de propósito — cache que
  /// cresce com o que o usuário rolou passa a se parecer com o acervo inteiro sem
  /// ser, e aí o app offline mente sobre o que existe.
  Future<Map<String, List<Book>>> fetchAndSaveCatalog({String? token}) async {
    final url = Uri.parse('$apiBaseUrl/api/books/catalog');
    final prefs = await SharedPreferences.getInstance();
    final locale = await RequestContext.currentLocaleTag();

    try {
      final response = await _client
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(ApiTimeouts.heavy);

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
      throw ApiException.fromResponse(response);
    } catch (e) {
      final failure = ApiException.fromError(e);
      if (kDebugMode) {
        debugPrint('Erro na requisicao do catalogo: $failure');
      }
      throw failure;
    }
  }

  Future<PagedResult<Book>> searchBooks(
    String query, {
    int page = 0,
    String? token,
  }) {
    return _fetchBookPage(
      Uri.parse('$apiBaseUrl/api/books/public/search').replace(
        queryParameters: <String, dynamic>{
          'q': query,
          'page': '$page',
          'size': '20',
        },
      ),
      page: page,
      token: token,
      context: 'searchBooks',
    );
  }

  /// Uma página do gênero. `size` fica em 10 para casar com a fatia que o
  /// catálogo já mostra e com o padrão da rota (`@PageableDefault(size = 10)`);
  /// o teto global da API é 100.
  Future<PagedResult<Book>> getBooksByGenre(
    String genre, {
    int page = 0,
    String? token,
  }) {
    final base = Uri.parse(
      '$apiBaseUrl/api/books/genres/${Uri.encodeComponent(genre)}',
    );

    return _fetchBookPage(
      base.replace(
        queryParameters: <String, dynamic>{
          'page': '$page',
          'size': '10',
          'sort': _stableGenreSort,
        },
      ),
      page: page,
      token: token,
      context: 'getBooksByGenre',
    );
  }

  /// Uma página de `BookCardResponse`, seja de busca ou de gênero.
  ///
  /// O erro sai como [ApiException] (a taxonomia do app) e não como `Exception`
  /// de texto: quem pagina precisa distinguir "sem rede, tente de novo" de
  /// "recusado", e antes as duas coisas chegavam como a mesma frase.
  Future<PagedResult<Book>> _fetchBookPage(
    Uri url, {
    required int page,
    required String? token,
    required String context,
  }) async {
    try {
      final response = await _client
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(ApiTimeouts.standard);

      // 204 é o que a API responde para página fora do fim da lista.
      if (response.statusCode == 204) {
        return PagedResult<Book>.empty(page: page);
      }
      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException(ApiFailure.invalidResponse);
      }

      return PagedResult<Book>.fromEnvelope(
        decoded,
        itemFromMap: Book.fromMap,
        requestedPage: page,
      );
    } catch (e) {
      final failure = ApiException.fromError(e);
      if (kDebugMode) {
        debugPrint('Erro em $context: $failure');
      }
      throw failure;
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
