import 'dart:convert';
import 'package:lumilivre/utils/parsers.dart';

class Book {
  final int id;
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
    return Book(
      id: safeParseInt(map['id']),
      title:
          map['title'] ?? map['titulo'] ?? map['nome'] ?? 'Título Desconhecido',
      author: map['author'] ?? map['autor'] ?? 'Autor Desconhecido',
      imageUrl: map['imageUrl'] ?? map['imagem'] ?? '',
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
    int? id,
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
}
