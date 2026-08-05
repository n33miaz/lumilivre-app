/// Uma página de resultados, como a API entrega.
///
/// As rotas paginadas da API devolvem o envelope padrão do Spring `Page`
/// (`content`, `number`, `last`, `totalElements`, ...). O app descartava tudo
/// menos o `content` e adivinhava o fim da lista por "veio vazio" — o que custa
/// uma requisição extra em toda categoria e erra quando a última página está
/// cheia. [isLast] vem do próprio servidor.
class PagedResult<T> {
  const PagedResult({
    required this.items,
    required this.page,
    required this.isLast,
  });

  final List<T> items;
  final int page;

  /// Não há próxima página. Quem pagina para de pedir.
  final bool isLast;

  /// Página vazia — o que a API responde com `204 No Content`.
  factory PagedResult.empty({int page = 0}) =>
      PagedResult<T>(items: <T>[], page: page, isLast: true);

  /// Lê o envelope do Spring.
  ///
  /// [requestedPage] é usado quando o corpo não traz `number`: o app precisa
  /// saber qual página acabou de chegar para calcular a próxima, e essa
  /// informação ele já tem.
  factory PagedResult.fromEnvelope(
    Map<String, dynamic> body, {
    required T Function(Map<String, dynamic> item) itemFromMap,
    required int requestedPage,
  }) {
    final rawContent = body['content'];
    final items = rawContent is List
        ? rawContent
              .whereType<Map<String, dynamic>>()
              .map(itemFromMap)
              .toList(growable: false)
        : <T>[];

    final rawLast = body['last'];
    final rawNumber = body['number'];

    return PagedResult<T>(
      items: items,
      page: rawNumber is int ? rawNumber : requestedPage,
      // Sem o `last` do servidor sobra a única inferência possível: página vazia
      // é fim de lista.
      isLast: rawLast is bool ? rawLast : items.isEmpty,
    );
  }
}
