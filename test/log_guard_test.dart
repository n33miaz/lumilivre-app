import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guarda de regressão: nenhum log solto no release.
///
/// O APK é distribuído por download direto e o `logcat` do Android é legível por
/// qualquer ferramenta ligada ao aparelho. Um `debugPrint` que sobrevive ao
/// release entrega o que estiver na mensagem — corpo de resposta com dado de
/// aluno, mensagem de erro da API, token.
///
/// A regra que este teste cobra é a mesma que o código já segue: `kDebugMode` na
/// própria linha, ou o `debugPrint` dentro de um bloco aberto por
/// `if (kDebugMode) {` na linha anterior.
void main() {
  test('nenhum debugPrint/print fora de kDebugMode em lib/', () {
    final offenders = <String>[];

    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        // Clientes gerados pelo openapi-generator: não editamos à mão.
        .where(
          (file) => !file.path.replaceAll(r'\', '/').contains('lib/api/gen/'),
        );

    for (final file in files) {
      final lines = file.readAsLinesSync();

      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        final code = line.trim();

        if (code.startsWith('//') || code.startsWith('*')) {
          continue;
        }
        if (!RegExp(r'(?<![\w.])(debugPrint|print)\s*\(').hasMatch(code)) {
          continue;
        }
        if (code.contains('kDebugMode')) {
          continue;
        }

        final previous = i > 0 ? lines[i - 1].trim() : '';
        if (previous == 'if (kDebugMode) {') {
          continue;
        }

        offenders.add('${file.path}:${i + 1}: $code');
      }
    }

    expect(offenders, isEmpty, reason: 'log sem guarda de kDebugMode');
  });

  test('nenhum log de corpo de requisicao/resposta em lib/', () {
    final offenders = <String>[];

    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where(
          (file) => !file.path.replaceAll(r'\', '/').contains('lib/api/gen/'),
        );

    // `response.body`/`bodyBytes` dentro de um log continua vazando mesmo em
    // debug — e é exatamente o achado que originou esta guarda.
    final pattern = RegExp(
      r'(debugPrint|print)\s*\([^;]*\b(body|bodyBytes|password|token)\b',
    );

    for (final file in files) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final code = lines[i].trim();
        if (code.startsWith('//')) {
          continue;
        }
        if (pattern.hasMatch(code)) {
          offenders.add('${file.path}:${i + 1}: $code');
        }
      }
    }

    expect(offenders, isEmpty, reason: 'log expondo corpo/credencial');
  });
}
