import 'dart:convert';

import 'package:lumilivre/utils/parsers.dart';

BookDetails bookDetailsFromJson(String str) =>
    BookDetails.fromJson(json.decode(str));

class BookDetails {
  final String id;
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
    required this.id,
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
    final genresRaw = json['generos'] ?? json['genres'];
    return BookDetails(
      id: json['id']?.toString() ?? '',
      isbn: (json['isbn'] ?? 'N/A').toString(),
      nome: (json['nome'] ?? json['title'] ?? 'Título Indisponível').toString(),
      dataLancamento: parseDate(
        json['dataLancamento'] ?? json['publicationDate'],
        fallback: () => DateTime(1900, 1, 1),
      ),
      numeroPaginas: safeParseInt(json['numeroPaginas'] ?? json['pageCount']),
      cdd: (json['cdd'] ?? json['deweyCode'] ?? 'N/A').toString(),
      editora: (json['editora'] ?? json['publisher'] ?? 'Editora não informada')
          .toString(),
      classificacaoEtaria:
          (json['classificacaoEtaria'] ??
                  json['ageRating']?['label'] ??
                  'Livre')
              .toString(),
      edicao:
          json['edicao']?.toString() ?? json['edition']?.toString() ?? 'N/A',
      volume: json['volume'] as int?,
      sinopse:
          (json['sinopse'] ?? json['synopsis'] ?? 'Sinopse não disponível.')
              .toString(),
      autor: (json['autor'] ?? json['author'] ?? 'Autor desconhecido')
          .toString(),
      tipoCapa:
          (json['tipoCapa'] ?? json['coverType']?['label'] ?? 'Capa comum')
              .toString(),
      imagem: (json['imagem'] ?? json['coverUrl'])?.toString(),
      generos: genresRaw is List
          ? genresRaw
                .map((e) => e?.toString() ?? '')
                .where((e) => e.isNotEmpty)
                .toList()
          : [],
      exemplaresDisponiveis: safeParseInt(json['exemplaresDisponiveis']),
      totalExemplares: safeParseInt(json['totalExemplares']),
      rating: safeParseDouble(json['avaliacao'] ?? json['rating'] ?? 4.6),
    );
  }
}
