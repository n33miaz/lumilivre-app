/// Utilitários de parsing seguros para dados dinâmicos da API.
library;

import 'package:flutter/foundation.dart' show kDebugMode;

/// Converte datas da API que podem vir como List [y,m,d], String ISO ou null.
///
/// [fallback] define o valor retornado quando a conversão falha.
/// Para datas históricas (BookDetails), usar `DateTime(1900, 1, 1)`.
/// Para datas operacionais (Loan), usar `DateTime.now()`.
DateTime parseDate(dynamic dateVal, {required DateTime Function() fallback}) {
  if (dateVal == null) {
    return fallback();
  }
  try {
    if (dateVal is List) {
      final y = dateVal.isNotEmpty ? (dateVal[0] as int) : 1900;
      final m = dateVal.length > 1 ? (dateVal[1] as int) : 1;
      final d = dateVal.length > 2 ? (dateVal[2] as int) : 1;
      return DateTime(y, m, d);
    }
    return DateTime.parse(dateVal.toString());
  } catch (_) {
    return fallback();
  }
}

/// Converte valores dinâmicos da API para [int]
int safeParseInt(dynamic value) {
  if (value == null) {
    return 0;
  }
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

/// Converte valores dinâmicos da API para [double]
double safeParseDouble(dynamic value) {
  if (value == null) {
    return 0.0;
  }
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
  }
  return 0.0;
}

/// Devolve a URL de mídia (capa, avatar, anexo) pronta para uso, ou `null`
/// quando ela não é confiável — nesse caso quem chama cai no asset local.
///
/// O valor vem do banco e é editável pelo painel: não é entrada confiável.
/// Duas regras:
///
/// - `http://` sobe para `https://`. Capa e, principalmente, **foto do aluno**
///   baixadas em claro entregam a imagem a qualquer um na mesma rede, e em
///   Android 9+ o tráfego em claro é recusado pela plataforma no flavor `prod`
///   (`usesCleartextTraffic=false`) — renderizar viraria erro silencioso.
/// - Esquema que não seja http(s) é **recusado**: `data:`, `file:`,
///   `javascript:` ou caminho relativo não têm razão de aparecer aqui e são o
///   caminho curto para carregar conteúdo local ou injetado.
///
/// Em debug o cleartext continua valendo para host da própria máquina ou de
/// rede privada, porque o stack local serve as imagens por
/// `http://localhost:8080/storage/...` (mesma tolerância do flavor `dev`).
String? secureMediaUrl(dynamic rawUrl) {
  if (rawUrl == null) {
    return null;
  }
  final text = rawUrl.toString().trim();
  if (text.isEmpty) {
    return null;
  }

  final uri = Uri.tryParse(text);
  if (uri == null || !uri.hasScheme) {
    return null;
  }

  switch (uri.scheme.toLowerCase()) {
    case 'https':
      return text;
    case 'http':
      if (kDebugMode && _isPrivateHost(uri.host)) {
        return text;
      }
      return uri.replace(scheme: 'https').toString();
    default:
      return null;
  }
}

/// A mesma URL de [secureMediaUrl], com uma marca de versão vinda do
/// `updatedAt` do recurso.
///
/// Capa é guardada em cache **pela URL** (o `cached_network_image` grava no
/// disco), e a URL não muda quando a bibliotecária troca a imagem do livro: o app
/// mostrava a capa antiga até alguém desinstalar. O `updatedAt` que o card da API
/// agora traz é a única coisa que muda junto com o livro, então ele vira o `v` da
/// query. Era o dado que faltava para fechar isto.
///
/// Idempotente de propósito: reescrever a mesma marca devolve a mesma URL, e é
/// isso que permite guardar o resultado no cache local e reparsear depois sem
/// invalidar imagem nenhuma. Sem `updatedAt`, nada muda.
String? versionedMediaUrl(dynamic rawUrl, dynamic updatedAt) {
  final url = secureMediaUrl(rawUrl);
  if (url == null) {
    return null;
  }

  final stamp = DateTime.tryParse(updatedAt?.toString() ?? '');
  if (stamp == null) {
    return url;
  }

  final uri = Uri.parse(url);
  return uri
      .replace(
        queryParameters: <String, String>{
          ...uri.queryParameters,
          'v': '${stamp.millisecondsSinceEpoch}',
        },
      )
      .toString();
}

/// Host de loopback ou de faixa privada (RFC 1918), incluindo o `10.0.2.2` que
/// o emulador Android usa para alcançar o host.
bool _isPrivateHost(String host) {
  final h = host.toLowerCase();
  if (h == 'localhost' || h == '::1' || h.endsWith('.local')) {
    return true;
  }
  if (h.startsWith('127.') || h.startsWith('10.') || h.startsWith('192.168.')) {
    return true;
  }
  final match = RegExp(r'^172\.(\d{1,2})\.').firstMatch(h);
  if (match != null) {
    final second = int.tryParse(match.group(1)!) ?? 0;
    return second >= 16 && second <= 31;
  }
  return false;
}

extension StringExtension on String {
  /// Retorna a string com a primeira letra em maiúscula e o restante em minúscula.
  String toCapitalized() {
    if (isEmpty) return '';
    if (length == 1) return toUpperCase();
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}
