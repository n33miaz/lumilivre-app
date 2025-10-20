import 'dart:convert';

List<Loan> loanFromJson(String str) =>
    List<Loan>.from(json.decode(str).map((x) => Loan.fromJson(x)));

class Loan {
  final int id;
  final DateTime dataEmprestimo;
  final DateTime dataDevolucao;
  final String status;
  final String? penalidade;
  final String livroTitulo;
  final String? imagemUrl;

  Loan({
    required this.id,
    required this.dataEmprestimo,
    required this.dataDevolucao,
    required this.status,
    this.penalidade,
    required this.livroTitulo,
    this.imagemUrl,
  });

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json["id"],
    dataEmprestimo: DateTime.parse(json["dataEmprestimo"]),
    dataDevolucao: DateTime.parse(json["dataDevolucao"]),
    status: json["status"],
    penalidade: json["penalidade"],
    livroTitulo: json["livroTitulo"],
    imagemUrl: json["imagemUrl"],
  );
}
