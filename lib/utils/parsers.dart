/// Utilitários de parsing seguros para dados dinâmicos da API.
library;

/// Converte datas da API que podem vir como List [y,m,d], String ISO ou null.
///
/// [fallback] define o valor retornado quando a conversão falha.
/// Para datas históricas (BookDetails), usar `DateTime(1900, 1, 1)`.
/// Para datas operacionais (Loan), usar `DateTime.now()`.
DateTime parseDate(dynamic dateVal, {required DateTime Function() fallback}) {
  if (dateVal == null) { return fallback(); }
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
  if (value == null) { return 0; }
  if (value is int) { return value; }
  if (value is double) { return value.toInt(); }
  if (value is String) { return int.tryParse(value) ?? 0; }
  return 0;
}

/// Converte valores dinâmicos da API para [double]
double safeParseDouble(dynamic value) {
  if (value == null) { return 0.0; }
  if (value is double) { return value; }
  if (value is int) { return value.toDouble(); }
  if (value is String) {
    return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
  }
  return 0.0;
}
