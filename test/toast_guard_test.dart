import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guarda de regressão: aviso transitório só sai por `AppToast`.
///
/// A pergunta do dono era "todos os alertas têm toast?". A resposta só continua
/// sendo "sim" se ninguém voltar a montar `SnackBar` à mão — foi exatamente
/// assim que o app juntou doze avisos com cor, duração e comportamento de fila
/// diferentes, nenhum com tempo de leitura pensado.
///
/// `AppToast` não é um segundo sistema de notificação: é o mesmo
/// `ScaffoldMessenger`/`SnackBar`, montado num lugar só. Este teste protege esse
/// "um lugar só".
void main() {
  /// Onde o mecanismo mora de verdade — o único arquivo autorizado.
  const toastImplementation = 'lib/widgets/app_toast.dart';

  Iterable<File> libFiles() => Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      // Clientes gerados pelo openapi-generator: não editamos à mão.
      .where(
        (file) => !file.path.replaceAll(r'\', '/').contains('lib/api/gen/'),
      )
      .where((file) => file.path.replaceAll(r'\', '/') != toastImplementation);

  test('nenhum SnackBar montado fora do AppToast', () {
    final offenders = <String>[];
    final pattern = RegExp(r'(showSnackBar|ScaffoldMessenger\.of|SnackBar\()');

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
      reason: 'aviso transitório deve passar por AppToast.of(context)',
    );
  });

  test('AppToast continua sendo o mecanismo que o projeto já usava', () {
    // Se algum dia isto falhar, alguém trocou o SnackBar por um overlay próprio —
    // que é justamente o segundo sistema de notificação que não queremos.
    final source = File(toastImplementation).readAsStringSync();
    expect(source, contains('showSnackBar'));
    expect(source, contains('hideCurrentSnackBar'));
  });
}
