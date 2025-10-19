import 'dart:convert';

BookDetails bookDetailsFromJson(String str) =>
    BookDetails.fromJson(json.decode(str));

class BookDetails {
  final String isbn; // inutilizavel?
  final String nome;
  final DateTime dataLancamento;
  final int numeroPaginas;
  final String cdd;
  final String editora;
  final String classificacaoEtaria;
  final String edicao; // inutilizavel?
  final int? volume; // inutilizavel?
  final String sinopse;
  final String autor;
  final String tipoCapa;
  final String? imagem;
  final List<String> generos;
  // final double? averageRating;
  // final int? ratingsCount;

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
  });

  factory BookDetails.fromJson(Map<String, dynamic> json) => BookDetails(
    isbn: json["isbn"],
    nome: json["nome"],
    dataLancamento: DateTime.parse(json["data_lancamento"]),
    numeroPaginas: json["numero_paginas"],
    cdd: json["cdd"],
    editora: json["editora"],
    classificacaoEtaria: json["classificacao_etaria"],
    edicao: json["edicao"],
    volume: json["volume"],
    sinopse: json["sinopse"],
    autor: json["autor"],
    tipoCapa: json["tipo_capa"],
    imagem: json["imagem"],
    generos: List<String>.from(json["generos"].map((x) => x['nome'])),
  );
}
