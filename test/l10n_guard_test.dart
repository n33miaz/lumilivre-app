import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guarda de regressão: os cinco ARB carregam o mesmo conjunto de chaves.
///
/// Chave que existe no `pt` e falta no `zh` não quebra o build e não aparece no
/// `flutter analyze`: o gerador só imprime um aviso e a tela fica com a frase em
/// português no meio do chinês — ou em branco, quando o rótulo é o texto todo.
/// É o tipo de furo que só aparece quando alguém abre o app naquele idioma
/// naquela tela, e ninguém abre.
///
/// Por isso a conferência é por **conjunto**, não a olho: adicionar um idioma
/// significa preencher as 181 chaves, e adicionar uma chave significa preencher
/// os cinco idiomas.
void main() {
  const arbDir = 'lib/l10n';

  /// Locale de referência: é o `template-arb-file` do `l10n.yaml`.
  const template = 'pt';

  Map<String, Map<String, dynamic>> readBundles() {
    final bundles = <String, Map<String, dynamic>>{};

    for (final file in Directory(arbDir).listSync().whereType<File>()) {
      final name = file.uri.pathSegments.last;
      if (!name.startsWith('app_') || !name.endsWith('.arb')) {
        continue;
      }
      final code = name.substring('app_'.length, name.length - '.arb'.length);
      bundles[code] =
          json.decode(file.readAsStringSync()) as Map<String, dynamic>;
    }

    return bundles;
  }

  /// Só as mensagens. `@@locale` é cabeçalho e `@chave` é metadado.
  Set<String> messageKeys(Map<String, dynamic> bundle) =>
      bundle.keys.where((key) => !key.startsWith('@')).toSet();

  test('os cinco idiomas existem', () {
    expect(
      readBundles().keys.toSet(),
      {'pt', 'en', 'es', 'zh', 'hi'},
      reason: 'idioma novo precisa de ARB próprio e de supportedLocales',
    );
  });

  test('todos os ARB têm exatamente o mesmo conjunto de chaves', () {
    final bundles = readBundles();
    final expected = messageKeys(bundles[template]!);

    // Comparação de conjuntos nos dois sentidos: falta e sobra são erros
    // diferentes (texto em branco vs. chave morta que ninguém traduz depois).
    for (final entry in bundles.entries) {
      if (entry.key == template) {
        continue;
      }
      final actual = messageKeys(entry.value);

      expect(
        actual.difference(expected),
        isEmpty,
        reason: 'app_${entry.key}.arb tem chave que não existe no template',
      );
      expect(
        expected.difference(actual),
        isEmpty,
        reason: 'app_${entry.key}.arb não traduziu estas chaves',
      );
    }
  });

  test('nenhuma tradução ficou vazia', () {
    for (final entry in readBundles().entries) {
      for (final key in messageKeys(entry.value)) {
        expect(
          (entry.value[key] as String).trim(),
          isNotEmpty,
          reason: 'app_${entry.key}.arb: $key sem texto',
        );
      }
    }
  });

  test('o @@locale de cada arquivo bate com o nome do arquivo', () {
    for (final entry in readBundles().entries) {
      expect(
        entry.value['@@locale'],
        entry.key,
        reason: 'app_${entry.key}.arb declara outro locale',
      );
    }
  });

  test('interpolação e plural preservam os mesmos placeholders', () {
    final bundles = readBundles();
    final reference = bundles[template]!;

    final placeholder = RegExp(r'\{(\w+)\}');
    // Nomes de categoria de plural ICU não são placeholders — são a sintaxe.
    const pluralCategories = <String>{
      'zero',
      'one',
      'two',
      'few',
      'many',
      'other',
    };

    Set<String> placeholdersOf(String message) => placeholder
        .allMatches(message)
        .map((match) => match.group(1)!)
        .where((name) => !pluralCategories.contains(name))
        .toSet();

    for (final key in messageKeys(reference)) {
      final expected = placeholdersOf(reference[key] as String);

      for (final entry in bundles.entries) {
        if (entry.key == template) {
          continue;
        }
        expect(
          placeholdersOf(entry.value[key] as String),
          expected,
          // Placeholder trocado de nome não compila; placeholder esquecido
          // compila e mostra a frase sem o dado — a data, o nome, a contagem.
          reason: 'app_${entry.key}.arb: $key mudou os placeholders',
        );
      }
    }
  });

  test('chave com plural no template tem plural em todos os idiomas', () {
    final bundles = readBundles();
    final reference = bundles[template]!;
    final plural = RegExp(r'\{\w+,\s*plural,');

    for (final key in messageKeys(reference)) {
      if (!plural.hasMatch(reference[key] as String)) {
        continue;
      }

      for (final entry in bundles.entries) {
        expect(
          plural.hasMatch(entry.value[key] as String),
          isTrue,
          // Traduzir plural como frase fixa é o erro clássico: some a
          // concordância e "1 dias" volta para a tela.
          reason: 'app_${entry.key}.arb: $key perdeu a forma plural',
        );
      }
    }
  });
}
