import 'dart:convert';
import 'package:lumilivre/utils/parsers.dart';

List<Loan> loanFromJson(String str) {
  final decoded = json.decode(str);
  if (decoded == null) {
    return [];
  }
  if (decoded is! List) {
    return [];
  }
  return List<Loan>.from(decoded.map((x) => Loan.fromJson(x)));
}

class Loan {
  final int id;
  final DateTime dataEmprestimo;
  final DateTime dataDevolucao;
  final String status;
  final String? penalidade;
  final int livroId;
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
      id: safeParseInt(json["id"]),
      dataEmprestimo: parseDate(json["dataEmprestimo"], fallback: DateTime.now),
      dataDevolucao: parseDate(json["dataDevolucao"], fallback: DateTime.now),
      status: json["status"]?.toString() ?? "DESCONHECIDO",
      penalidade: json["penalidade"]?.toString(),
      livroId: safeParseInt(json["livroId"]),
      livroTitulo: json["livroTitulo"]?.toString() ?? "Livro sem título",
      imagemUrl: json["imagemUrl"]?.toString(),
      isRequest: false,
    );
  }

  factory Loan.fromRequestJson(Map<String, dynamic> json) {
    return Loan(
      id: json["id"] ?? 0,
      dataEmprestimo: parseDate(
        json["dataSolicitacao"],
        fallback: DateTime.now,
      ),
      dataDevolucao: DateTime(2100),
      status: json["status"] ?? "PENDENTE",
      livroId: json["livroId"] ?? 0,
      livroTitulo: json["livroNome"] ?? "Solicitação",
      imagemUrl: null,
      isRequest: true,
    );
  }
}
