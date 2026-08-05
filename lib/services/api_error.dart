import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Por que uma chamada à API não devolveu dado.
///
/// Existe para a tela poder responder de formas diferentes: "sem internet" pede
/// nova tentativa, "precisa de sessão" pede login. Antes tudo virava a mesma
/// `Exception` de texto e o convidado recebia cara de falha de rede ao abrir um
/// livro que a API só entrega para leitor autenticado.
enum ApiFailure {
  /// Sem conexão, DNS, timeout — tentar de novo faz sentido.
  network,

  /// 401/403: falta sessão (convidado) ou a sessão não vale mais.
  unauthorized,

  /// 404: recurso não existe mais.
  notFound,

  /// 5xx e demais respostas inesperadas do servidor.
  server,

  /// Resposta chegou, mas não deu para interpretar (JSON fora do contrato).
  invalidResponse,
}

class ApiException implements Exception {
  const ApiException(this.failure, {this.statusCode});

  final ApiFailure failure;
  final int? statusCode;

  bool get needsAuthentication => failure == ApiFailure.unauthorized;

  /// Falha em que repetir a mesma chamada pode dar certo.
  bool get isRetryable =>
      failure == ApiFailure.network || failure == ApiFailure.server;

  /// Traduz o status HTTP em motivo. Note que a API responde 401 tanto para
  /// token ausente quanto para token expirado — quem decide a mensagem é a tela,
  /// olhando se existe sessão.
  factory ApiException.fromStatus(int statusCode) {
    if (statusCode == 401 || statusCode == 403) {
      return ApiException(ApiFailure.unauthorized, statusCode: statusCode);
    }
    if (statusCode == 404) {
      return ApiException(ApiFailure.notFound, statusCode: statusCode);
    }
    return ApiException(ApiFailure.server, statusCode: statusCode);
  }

  /// Classifica o erro que veio do cliente HTTP.
  ///
  /// `http` embala falha de socket em `ClientException`, então o tipo sozinho não
  /// distingue "servidor fora do ar" de "resposta corrompida" — ambos caem em
  /// [ApiFailure.network], que é o que a tela precisa saber (oferecer retry).
  factory ApiException.fromError(Object error) {
    if (error is ApiException) {
      return error;
    }
    if (error is TimeoutException ||
        error is SocketException ||
        error is HttpException ||
        error is http.ClientException) {
      return const ApiException(ApiFailure.network);
    }
    if (error is FormatException || error is TypeError) {
      return const ApiException(ApiFailure.invalidResponse);
    }
    return const ApiException(ApiFailure.server);
  }

  /// Sem corpo de resposta e sem token: esta string pode acabar em log.
  @override
  String toString() =>
      'ApiException(${failure.name}${statusCode != null ? ', $statusCode' : ''})';
}
