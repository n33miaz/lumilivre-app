import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/book.dart';

/// A lista de curtidos que ficou no aparelho de antes de o interesse existir no
/// servidor (`SharedPreferences`, chave `favoriteBooks`).
///
/// **Esta classe existe para ser esvaziada.** Descartar a lista em silêncio
/// apagaria a única cópia do que a pessoa curtiu; mandar tudo de uma vez sem
/// controle repetiria o envio a cada abertura do app. Então a lista antiga passa
/// a ser uma **fila de trabalho**: [pending] diz o que ainda não subiu, [drop]
/// tira do backlog o que subiu (ou o que nunca vai subir) e [finish] fecha a
/// migração para sempre. Depois que [isDone] responde `true`, ninguém mais lê a
/// chave antiga — nem o leitor seguinte que usar o mesmo aparelho.
///
/// Marcar interesse é idempotente na API, então uma migração interrompida no meio
/// (sem rede, senha inicial pendente) retoma na próxima sessão sem duplicar nada.
class LegacyFavoritesStore {
  /// Chave escrita pelas versões em que o curtir morava só no aparelho.
  static const String favoritesKey = 'favoriteBooks';

  /// Migração concluída. Só é escrita quando o backlog esvazia — meia migração
  /// não vira migração feita.
  static const String doneKey = 'interest_legacy_migrated_v1';

  Future<bool> isDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(doneKey) ?? false;
  }

  /// Livros da lista antiga que ainda não subiram.
  ///
  /// Entrada corrompida (JSON de uma versão antiga do modelo) e livro sem id são
  /// descartados aqui: não há o que enviar sem id, e um item ilegível travaria a
  /// migração para sempre.
  Future<List<Book>> pending() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(favoritesKey);
    if (stored == null || stored.isEmpty) {
      return const [];
    }

    final books = <Book>[];
    final seen = <String>{};
    for (final entry in stored) {
      try {
        final book = Book.fromJson(entry);
        if (book.id.isNotEmpty && seen.add(book.id)) {
          books.add(book);
        }
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Curtido local ilegivel descartado: $e');
        }
      }
    }
    return books;
  }

  /// Tira um livro do backlog, tenha ele subido ou sido recusado de forma
  /// definitiva (id que não é UUID, livro que saiu do acervo).
  Future<void> drop(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(favoritesKey);
    if (stored == null) {
      return;
    }

    final remaining = stored.where((entry) {
      try {
        return Book.fromJson(entry).id != bookId;
      } catch (_) {
        return false;
      }
    }).toList();

    await prefs.setStringList(favoritesKey, remaining);
  }

  /// Fecha a migração: apaga a chave antiga e registra que ela já foi lida.
  Future<void> finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(favoritesKey);
    await prefs.setBool(doneKey, true);
  }
}
