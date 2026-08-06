import 'book.dart';

/// Um livro que o leitor marcou como interesse, e o instante em que marcou.
///
/// O `markedAt` vem do servidor e não é enfeite: é ele que dá a ordem de
/// `interests/mine` (mais recente primeiro) e é ele que permite pôr no topo da
/// aba o livro que acabou de ser curtido, sem pedir a página de novo.
class BookInterest {
  const BookInterest({required this.book, this.markedAt});

  final Book book;

  /// `null` só no interesse que ainda não voltou do servidor (pintura otimista)
  /// ou em cache antigo. A API sempre manda.
  final DateTime? markedAt;

  /// Item de `interests/mine`: `{book: BookCardResponse, markedAt}`.
  ///
  /// Aceita o mapa sem o embrulho `book` para o cache local poder guardar a
  /// mesma forma que a API devolve sem depender dela.
  factory BookInterest.fromMap(Map<String, dynamic> map) {
    final rawBook = map['book'];

    return BookInterest(
      book: Book.fromMap(rawBook is Map<String, dynamic> ? rawBook : map),
      markedAt: parseNullableInstant(map['markedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'book': book.toMap(),
    'markedAt': markedAt?.toIso8601String(),
  };
}

/// Estado que o servidor **aceitou** para o interesse do leitor em um livro.
///
/// É a resposta de `POST` e `DELETE /api/books/{id}/interest` — as duas mandam
/// corpo, com a mesma forma, justamente para o app ter um caminho só de leitura.
/// Adotar este estado (em vez de assumir o que a tela pintou) é o que faz o
/// coração convergir com o servidor: marcar duas vezes devolve `interested:true`
/// com o `markedAt` da primeira, e desmarcar o que não estava marcado devolve
/// `interested:false` em vez de erro.
class InterestState {
  const InterestState({
    required this.bookId,
    required this.interested,
    this.markedAt,
  });

  final String bookId;
  final bool interested;
  final DateTime? markedAt;

  factory InterestState.fromMap(Map<String, dynamic> map) => InterestState(
    bookId: map['bookId']?.toString() ?? '',
    interested: map['interested'] == true,
    markedAt: parseNullableInstant(map['markedAt']),
  );
}

/// Instante ISO-8601 com deslocamento (`OffsetDateTime` da API) em hora local,
/// ou `null` quando não veio ou não dá para ler.
///
/// Diferente de `parseDate`: aqui a ausência é informação (interesse desmarcado
/// devolve `markedAt: null`), então não há data de fallback a inventar.
DateTime? parseNullableInstant(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString())?.toLocal();
}
