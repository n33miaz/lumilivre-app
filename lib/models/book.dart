import 'dart:convert';

import 'package:lumilivre/utils/parsers.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String imageUrl;
  final double rating;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'rating': rating,
    };
  }

  String toJson() => json.encode(toMap());

  factory Book.fromMap(Map<String, dynamic> map) {
    final rawImage = map['imageUrl'] ?? map['coverUrl'] ?? map['imagem'];

    return Book(
      id: _idToString(map['id']),
      title:
          (map['title'] ??
                  map['titulo'] ??
                  map['nome'] ??
                  'Título Desconhecido')
              .toString(),
      author: (map['author'] ?? map['autor'] ?? 'Autor Desconhecido')
          .toString(),
      // URL recusada vira string vazia: o card já trata isso como "sem capa"
      // e desenha a capa padrão local. O `updatedAt` do card entra como versão
      // da imagem — sem ele, trocar a capa no painel não trocava a capa no
      // celular. Cache local reparseado não tem o campo e mantém a URL que já
      // veio versionada.
      imageUrl: versionedMediaUrl(rawImage, map['updatedAt']) ?? '',
      rating: safeParseDouble(map['rating'] ?? map['avaliacao']),
    );
  }

  factory Book.fromJson(String source) => Book.fromMap(json.decode(source));

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is Book &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.imageUrl == imageUrl &&
        other.rating == rating;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      author.hashCode ^
      imageUrl.hashCode ^
      rating.hashCode;

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? imageUrl,
    double? rating,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
    );
  }

  static String _idToString(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String || value is num) {
      return value.toString();
    }
    return '';
  }
}
