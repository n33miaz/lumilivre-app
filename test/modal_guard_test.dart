import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guarda de regressão: modal só abre pelo helper do app.
///
/// O estado que originou esta guarda: cinco modais, cada um escolhendo cor de
/// fundo, raio, alça e animação por conta própria. O do ranking não passava cor
/// nenhuma e herdava o tom do Material 3, diferente da carta que o do mural
/// pintava à mão; os diálogos de senha ficavam com o raio 28 padrão ao lado do
/// tour, que desenhava 16.
///
/// `showAppDialog`/`showAppSheet` não são um sistema paralelo: são o
/// `showDialog`/`showModalBottomSheet` do Flutter, chamados de um lugar só, para
/// que decoração (via `dialogTheme`/`bottomSheetTheme`) e a saída de
/// `disableAnimations` valham para todos sem ninguém precisar lembrar.
void main() {
  /// Onde o mecanismo mora de verdade — o único arquivo autorizado.
  const modalImplementation = 'lib/widgets/app_modal.dart';

  Iterable<File> libFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      // Clientes gerados pelo openapi-generator: não editamos à mão.
      .where(
        (file) => !file.path.replaceAll(r'\', '/').contains('lib/api/gen/'),
      )
      .where((file) => file.path.replaceAll(r'\', '/') != modalImplementation);

  test('nenhum modal aberto fora do showAppDialog/showAppSheet', () {
    final offenders = <String>[];
    final pattern = RegExp(r'(showDialog|showModalBottomSheet)\s*[<(]');

    for (final file in libFiles()) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final code = lines[i].trim();
        // Comentário citando o mecanismo é documentação, não uso.
        if (code.startsWith('//') ||
            code.startsWith('///') ||
            code.startsWith('*')) {
          continue;
        }
        if (pattern.hasMatch(code)) {
          offenders.add('${file.path}:${i + 1}: $code');
        }
      }
    }

    expect(
      offenders,
      isEmpty,
      reason: 'modal deve passar por showAppDialog/showAppSheet',
    );
  });

  test('o helper usa o modal do Flutter, não um overlay proprio', () {
    final source = File(modalImplementation).readAsStringSync();
    expect(source, contains('showDialog<T>'));
    expect(source, contains('showModalBottomSheet<T>'));
  });
}
