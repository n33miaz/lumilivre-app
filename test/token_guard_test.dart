import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guarda de regressão: ninguém busca o token de sessão por conta própria.
///
/// O token fica gravado no `flutter_secure_storage` inclusive quando **não** pode
/// ser usado: em modo convidado, e quando o gate biométrico recusou a sessão
/// (nesses casos a sessão é mantida de propósito, para nova tentativa). Um
/// serviço que lê o armazenamento direto passa a mandar `Authorization` nessas
/// duas situações — a tela diz "Convidado" e o `access_log` da API registra o
/// leitor. Foi assim em `book_api` e depois em `catalog_api`.
///
/// A regra: quem responde qual token sai na requisição é o `AuthProvider`
/// (`sessionToken`), e o token desce por parâmetro até o serviço.
void main() {
  /// Donos legítimos do armazenamento: o próprio `AuthStorage` e o provider que
  /// grava/apaga a sessão.
  const allowed = <String>{
    'lib/services/auth_storage.dart',
    'lib/providers/auth.dart',
  };

  Iterable<File> dartFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      // Clientes gerados pelo openapi-generator: não editamos à mão.
      .where(
        (file) => !file.path.replaceAll(r'\', '/').contains('lib/api/gen/'),
      );

  String normalize(String path) => path.replaceAll(r'\', '/');

  test('nenhum serviço ou tela le o token do armazenamento seguro', () {
    final offenders = <String>[];
    final pattern = RegExp(r'\b(AuthStorage|FlutterSecureStorage)\b');

    for (final file in dartFiles()) {
      final path = normalize(file.path);
      if (allowed.contains(path)) {
        continue;
      }

      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final code = lines[i].trim();
        if (code.startsWith('//') || code.startsWith('*')) {
          continue;
        }
        if (pattern.hasMatch(code)) {
          offenders.add('$path:${i + 1}: $code');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'token de sessão deve vir de AuthProvider.sessionToken',
    );
  });
}
