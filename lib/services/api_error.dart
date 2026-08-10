import 'dart:async';
import 'dart:convert';
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

  /// 403 com `code: PASSWORD_CHANGE_REQUIRED`: a sessão é válida, mas a API
  /// segura tudo até a senha inicial ser trocada.
  ///
  /// Separado de [unauthorized] de propósito: aqui deslogar seria o pior
  /// caminho, porque a saída é justamente o formulário de troca de senha — que
  /// só existe dentro da sessão.
  passwordChangeRequired,

  /// 404: recurso não existe mais.
  notFound,

  /// 422/409/4xx de regra de negócio: o servidor entendeu e recusou. A frase do
  /// motivo vem em [ApiException.apiMessage].
  businessRule,

  /// 5xx e demais respostas inesperadas do servidor.
  server,

  /// Resposta chegou, mas não deu para interpretar (JSON fora do contrato).
  invalidResponse,
}

class ApiException implements Exception {
  const ApiException(this.failure, {this.statusCode, this.apiMessage});

  /// Quem quer saber que uma chamada falhou no transporte.
  ///
  /// Todo `catch` de todo serviço do app termina em [fromError] — é o único
  /// ponto por onde as dez classes de API já passam sem que nenhuma precise
  /// saber que existe um monitor de saúde escutando. O gancho é um campo, e não
  /// uma chamada direta ao monitor, por dois motivos: a taxonomia de erro não
  /// pode depender de quem faz HTTP (o monitor faz, e o erro dele voltaria para
  /// cá), e sem ninguém instalado — o caso dos testes de unidade — [fromError]
  /// continua sendo a função pura que sempre foi, sem timer nem rede por trás.
  static void Function(ApiFailure failure)? onFailure;

  final ApiFailure failure;
  final int? statusCode;

  /// Frase que a API mandou no campo `message` do erro, já traduzida pelo
  /// servidor (ele responde no idioma do `Accept-Language` que o app envia).
  ///
  /// Existe para a tela não adivinhar em português o que a API já sabe dizer:
  /// "conta desativada" e "senha incorreta" chegam por aqui e são frases
  /// diferentes que antes viravam a mesma copy de falha de conexão. Fica fora do
  /// [toString] porque texto de resposta não entra em log.
  final String? apiMessage;

  bool get needsAuthentication => failure == ApiFailure.unauthorized;

  bool get requiresPasswordChange =>
      failure == ApiFailure.passwordChangeRequired;

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

  /// Classifica a resposta olhando também o corpo do erro.
  ///
  /// Só o status não basta em dois casos que chegam como o mesmo 4xx: o 403 de
  /// senha inicial pendente (que não é falta de sessão) e as recusas de regra de
  /// negócio, cuja frase é a única informação útil para o usuário.
  factory ApiException.fromResponse(http.Response response) {
    final body = _decodeErrorBody(response);
    final code = body?['code']?.toString();
    final status = response.statusCode;

    if (status == 403 && code == 'PASSWORD_CHANGE_REQUIRED') {
      // A `message` deste caso é texto técnico em inglês, escrito para quem
      // depura a API — nunca para a tela. O app usa a própria copy.
      return ApiException(
        ApiFailure.passwordChangeRequired,
        statusCode: status,
      );
    }

    final rawMessage = body?['message']?.toString().trim();
    final message = (rawMessage == null || rawMessage.isEmpty)
        ? null
        : rawMessage;

    // 422 é o que as políticas de empréstimo/solicitação usam, 409 é conflito de
    // estado: nos dois o servidor já explica o motivo em pt-BR ou en-US.
    if (status == 422 || status == 409) {
      return ApiException(
        ApiFailure.businessRule,
        statusCode: status,
        apiMessage: message,
      );
    }

    return ApiException(
      ApiException.fromStatus(status).failure,
      statusCode: status,
      apiMessage: message,
    );
  }

  /// Corpo de erro da API como mapa, ou `null` quando não é o `ErrorResponse`
  /// esperado (204, HTML de proxy, texto solto). Nunca joga: um corpo estranho
  /// não pode transformar "recusado" em "erro inesperado".
  static Map<String, dynamic>? _decodeErrorBody(http.Response response) {
    if (response.bodyBytes.isEmpty) {
      return null;
    }
    try {
      final decoded = json.decode(utf8.decode(response.bodyBytes));
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  /// Classifica o erro que veio do cliente HTTP.
  ///
  /// `http` embala falha de socket em `ClientException`, então o tipo sozinho não
  /// distingue "servidor fora do ar" de "resposta corrompida" — ambos caem em
  /// [ApiFailure.network], que é o que a tela precisa saber (oferecer retry).
  factory ApiException.fromError(Object error) {
    final failure = classify(error);
    onFailure?.call(failure.failure);
    return failure;
  }

  /// A mesma classificação de [fromError], sem avisar [onFailure].
  ///
  /// Existe para quem já é o observador (o monitor de saúde) ou para quem está
  /// tratando um erro que **já foi** reportado — repetir o aviso não erra, mas
  /// esconde de quem lê o código que ali não nasce informação nova.
  static ApiException classify(Object error) {
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
