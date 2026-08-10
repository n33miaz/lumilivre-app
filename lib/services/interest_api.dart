import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book_interest.dart';
import '../models/paged_result.dart';
import '../utils/constants.dart';
import 'api_error.dart';
import 'request_context.dart';

/// Interesse do leitor pelo livro — o "curtir" do app, agora no servidor.
///
/// **Nenhuma rota recebe matrícula**: o leitor sai do token dentro da API, então
/// não há parâmetro em que trocar o dono do interesse. O token desce de quem
/// chama (`AuthProvider.sessionToken`) e nunca é lido do armazenamento seguro
/// aqui — em modo convidado e com o gate biométrico recusado o token continua
/// gravado justamente para poder ser reusado depois, e é assim que serviços que
/// leem o storage passam a mandar credencial que a UI já recusou.
///
/// O que fica no aparelho é **cache de leitura**, não a lista. A fonte da
/// verdade é `interests/mine`; o cache existe para o app abrir offline mostrando
/// o que o servidor disse por último, como o mural e o catálogo já fazem.
class InterestApi {
  InterestApi({http.Client? client}) : _client = client ?? http.Client();

  /// Cache da primeira página, por conta.
  ///
  /// A conta entra na chave porque dois leitores podem usar o mesmo aparelho: sem
  /// isso, a lista de quem entrou antes apareceria por um instante para quem
  /// entrou depois. Gravar limpa as chaves das outras contas, então o disco
  /// guarda no máximo a lista de quem está logado agora.
  static const String cacheKeyPrefix = 'interest_cache_v1_';

  /// Itens por página de `interests/mine`.
  ///
  /// Cinquenta e não vinte (o padrão da rota) porque esta lista faz dois papéis:
  /// alimenta a aba de curtidos **e** responde "este livro está marcado?" para o
  /// coração da ficha. Uma página cobre o acervo curtido de um leitor real, o que
  /// mantém a resposta do coração correta com uma requisição; o pager continua
  /// paginando para quem passar disso. O teto da API é 100.
  static const int minePageSize = 50;

  final http.Client _client;

  /// Marca interesse. A API responde **200 sempre** — marcar duas vezes devolve o
  /// mesmo corpo, com o `markedAt` da primeira vez —, então não há checagem
  /// prévia a fazer nem 409 a tratar.
  Future<InterestState> mark(String bookId, {required String token}) =>
      _write(bookId, token: token, clearing: false);

  /// Desmarca interesse. Também 200 com corpo, inclusive quando não estava
  /// marcado: o cliente pediu um estado e recebe o estado.
  Future<InterestState> unmark(String bookId, {required String token}) =>
      _write(bookId, token: token, clearing: true);

  Future<InterestState> _write(
    String bookId, {
    required String token,
    required bool clearing,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/books/$bookId/interest');

    try {
      final headers = await RequestContext.headers(token: token);
      final request = clearing
          ? _client.delete(url, headers: headers)
          : _client.post(url, headers: headers);
      final response = await request.timeout(ApiTimeouts.standard);

      if (response.statusCode != 200) {
        // `fromResponse` e não `fromStatus`: o 403 de senha inicial pendente só
        // se distingue de "sem sessão" pelo `code` do corpo, e é o erro esperado
        // nas **escritas** de interesse enquanto o leitor não trocar a senha.
        throw ApiException.fromResponse(response);
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException(ApiFailure.invalidResponse);
      }
      return InterestState.fromMap(decoded);
    } catch (e) {
      final failure = ApiException.fromError(e);
      if (kDebugMode) {
        debugPrint('Erro ao gravar interesse: $failure');
      }
      throw failure;
    }
  }

  /// Uma página da lista do próprio leitor.
  ///
  /// Sem `sort`: a consulta da API já tem `ORDER BY` (mais recente primeiro, com
  /// desempate por id) e o serviço **descarta** a ordenação do cliente. Mandar
  /// seria pedir ao servidor para ignorar.
  Future<PagedResult<BookInterest>> getMine({
    int page = 0,
    required String token,
  }) async {
    final url = Uri.parse('$apiBaseUrl/api/books/interests/mine').replace(
      queryParameters: <String, String>{
        'page': '$page',
        'size': '$minePageSize',
      },
    );

    try {
      final response = await _client
          .get(url, headers: await RequestContext.headers(token: token))
          .timeout(ApiTimeouts.standard);

      if (response.statusCode == 204) {
        return PagedResult<BookInterest>.empty(page: page);
      }
      if (response.statusCode != 200) {
        throw ApiException.fromResponse(response);
      }

      final decoded = json.decode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) {
        throw const ApiException(ApiFailure.invalidResponse);
      }

      return PagedResult<BookInterest>.fromEnvelope(
        decoded,
        itemFromMap: BookInterest.fromMap,
        requestedPage: page,
      );
    } catch (e) {
      final failure = ApiException.fromError(e);
      if (kDebugMode) {
        debugPrint('Erro ao listar interesses: $failure');
      }
      throw failure;
    }
  }

  /// Lista guardada no aparelho para [accountKey], ou vazia.
  ///
  /// Nunca joga: cache ilegível é cache ausente, e o app segue para a rede.
  Future<List<BookInterest>> cachedMine(String accountKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$cacheKeyPrefix$accountKey');
      if (raw == null || raw.isEmpty) {
        return const [];
      }

      final decoded = json.decode(raw);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(BookInterest.fromMap)
          .toList(growable: false);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao ler cache de interesses: $e');
      }
      return const [];
    }
  }

  Future<void> cacheMine(String accountKey, List<BookInterest> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$cacheKeyPrefix$accountKey';
      final others = _cacheKeys(prefs).where((k) => k != key);

      for (final other in others) {
        await prefs.remove(other);
      }

      await prefs.setString(
        key,
        json.encode(items.map((item) => item.toMap()).toList()),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao gravar cache de interesses: $e');
      }
    }
  }

  /// Apaga o cache de todas as contas. Chamado no logout: curtida é preferência
  /// de leitura de um menor de idade e não fica no aparelho depois que a sessão
  /// dela termina.
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in _cacheKeys(prefs)) {
        await prefs.remove(key);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Erro ao limpar cache de interesses: $e');
      }
    }
  }

  /// Chaves de cache de interesse hoje no aparelho, de qualquer conta.
  List<String> _cacheKeys(SharedPreferences prefs) => prefs
      .getKeys()
      .where((key) => key.startsWith(cacheKeyPrefix))
      .toList(growable: false);
}
