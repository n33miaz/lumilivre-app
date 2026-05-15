import 'dart:convert';

import 'package:lumilivre/utils/parsers.dart';

List<Loan> loanFromJson(String str) {
  final decoded = json.decode(str);
  if (decoded == null || decoded is! List) {
    return [];
  }
  return List<Loan>.from(decoded.map((x) => Loan.fromJson(x)));
}

class Loan {
  final String id;
  final DateTime dataEmprestimo;
  final DateTime dataDevolucao;
  final String status;
  final String? penalidade;
  final String livroId;
  final String livroTitulo;
  final String? imagemUrl;
  final bool isRequest;

  Loan({
    required this.id,
    required this.dataEmprestimo,
    required this.dataDevolucao,
    required this.status,
    this.penalidade,
    required this.livroId,
    required this.livroTitulo,
    this.imagemUrl,
    this.isRequest = false,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id']?.toString() ?? '',
      dataEmprestimo: parseDate(
        json['dataEmprestimo'] ?? json['borrowedAt'],
        fallback: DateTime.now,
      ),
      dataDevolucao: parseDate(
        json['dataDevolucao'] ?? json['dueAt'],
        fallback: DateTime.now,
      ),
      status: _codeOrString(json['status']) ?? 'DESCONHECIDO',
      penalidade:
          json['penalidade']?.toString() ?? _codeOrString(json['penaltyCode']),
      livroId: json['livroId']?.toString() ?? json['bookId']?.toString() ?? '',
      livroTitulo:
          json['livroTitulo']?.toString() ??
          json['bookTitle']?.toString() ??
          'Livro sem título',
      imagemUrl: json['imagemUrl']?.toString() ?? json['coverUrl']?.toString(),
      isRequest: false,
    );
  }

  factory Loan.fromRequestJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id']?.toString() ?? '',
      dataEmprestimo: parseDate(
        json['dataSolicitacao'] ?? json['requestedAt'],
        fallback: DateTime.now,
      ),
      dataDevolucao: DateTime(2100),
      status: _codeOrString(json['status']) ?? 'PENDENTE',
      livroId: json['livroId']?.toString() ?? json['bookId']?.toString() ?? '',
      livroTitulo:
          json['livroNome']?.toString() ??
          json['bookTitle']?.toString() ??
          'Solicitação',
      imagemUrl: null,
      isRequest: true,
    );
  }

  static String? _codeOrString(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is Map) {
      return value['code']?.toString();
    }
    return value.toString();
  }
}
