import 'dart:convert';
import 'package:lumilivre/utils/parsers.dart';

BookDetails bookDetailsFromJson(String str) =>
    BookDetails.fromJson(json.decode(str));

class BookDetails {
  final String isbn;
  final String nome;
  final DateTime dataLancamento;
  final int numeroPaginas;
  final String cdd;
  final String editora;
  final String classificacaoEtaria;
  final String edicao;
  final int? volume;
  final String sinopse;
  final String autor;
  final String tipoCapa;
  final String? imagem;
  final List<String> generos;
  final int exemplaresDisponiveis;
  final int totalExemplares;
  final double rating;

  BookDetails({
    required this.isbn,
    required this.nome,
    required this.dataLancamento,
    required this.numeroPaginas,
    required this.cdd,
    required this.editora,
    required this.classificacaoEtaria,
    required this.edicao,
    this.volume,
    required this.sinopse,
    required this.autor,
    required this.tipoCapa,
    this.imagem,
    required this.generos,
    required this.exemplaresDisponiveis,
    required this.totalExemplares,
    required this.rating,
  });

  factory BookDetails.fromJson(Map<String, dynamic> json) {
    return BookDetails(
      isbn: json["isbn"] ?? 'N/A',
      nome: json["nome"] ?? 'Título Indisponível',
      dataLancamento: parseDate(
        json["dataLancamento"],
        fallback: () => DateTime(1900, 1, 1),
      ),
      numeroPaginas: json["numeroPaginas"] ?? 0,
      cdd: json["cdd"] ?? 'N/A',
      editora: json["editora"] ?? 'Editora não informada',
      classificacaoEtaria: json["classificacaoEtaria"] ?? 'Livre',
      edicao: json["edicao"]?.toString() ?? 'N/A',
      volume: json["volume"],
      sinopse: json["sinopse"] ?? 'Sinopse não disponível.',
      autor: json["autor"] ?? 'Autor desconhecido',
      tipoCapa: json["tipoCapa"] ?? 'Capa comum',
      imagem: json["imagem"],
      generos: json["generos"] != null
          ? (json["generos"] as List)
                .map((e) => e?.toString() ?? "")
                .where((e) => e.isNotEmpty)
                .toList()
          : [],
      exemplaresDisponiveis: json["exemplaresDisponiveis"] ?? 0,
      totalExemplares: json["totalExemplares"] ?? 0,
      rating: (json["avaliacao"] as num?)?.toDouble() ?? 4.6,
    );
  }
}
