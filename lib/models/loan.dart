import 'dart:convert';

List<Loan> loanFromJson(String str) {
  final decoded = json.decode(str);
  if (decoded == null) return [];
  if (decoded is! List) return [];
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
    DateTime parseDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now();
      try {
        if (dateVal is List) {
          final y = dateVal.isNotEmpty ? (dateVal[0] as int) : 1900;
          final m = dateVal.length > 1 ? (dateVal[1] as int) : 1;
          final d = dateVal.length > 2 ? (dateVal[2] as int) : 1;
          return DateTime(y, m, d);
        }
        return DateTime.parse(dateVal.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return Loan(
      id: parseInt(json["id"]),
      dataEmprestimo: parseDate(json["dataEmprestimo"]),
      dataDevolucao: parseDate(json["dataDevolucao"]),
      status: json["status"]?.toString() ?? "DESCONHECIDO",
      penalidade: json["penalidade"]?.toString(),
      livroId: parseInt(json["livroId"]),
      livroTitulo: json["livroTitulo"]?.toString() ?? "Livro sem título",
      imagemUrl: json["imagemUrl"]?.toString(),
      isRequest: false,
    );
  }

  factory Loan.fromRequestJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateVal) {
      if (dateVal == null) return DateTime.now();
      try {
        return DateTime.parse(dateVal.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    return Loan(
      id: json["id"] ?? 0,
      dataEmprestimo: parseDate(
        json["dataSolicitacao"],
      ),
      dataDevolucao: DateTime(2100), 
      status: json["status"] ?? "PENDENTE",
      livroId: json["livroId"] ?? 0,
      livroTitulo: json["livroNome"] ?? "Solicitação",
      imagemUrl:
          null,
      isRequest: true,
    );
  }
}
