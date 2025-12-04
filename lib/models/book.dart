import 'dart:convert';

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

  // --- Serialização (Para salvar no Cache/Disco) ---

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
      'rating': rating, // Adicionado para persistir a nota no cache
    };
  }

  String toJson() => json.encode(toMap());

  // --- Desserialização (Ler da API ou Cache) ---

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: _toInt(map['id']),
      // Tenta ler 'title', se não achar tenta 'titulo' (comum em APIs pt-br), ou 'nome'
      title:
          map['title'] ?? map['titulo'] ?? map['nome'] ?? 'Título Desconhecido',
      author: map['author'] ?? map['autor'] ?? 'Autor Desconhecido',
      imageUrl: map['imageUrl'] ?? map['imagem'] ?? '',
      // Tenta ler 'rating', se não achar tenta 'avaliacao'
      rating: _toDouble(map['rating'] ?? map['avaliacao']),
    );
  }

  factory Book.fromJson(String source) => Book.fromMap(json.decode(source));

  // --- Métodos Auxiliares de Blindagem (Evita Crash) ---

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null)
      return 0.0; // Mudei o default de 4.6 para 0.0 (mais seguro)
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      // Troca vírgula por ponto caso venha "4,5"
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  // --- Otimização de Performance (Comparação de Objetos) ---

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Book &&
        other.id == id &&
        other.title == title &&
        other.author == author &&
        other.imageUrl == imageUrl &&
        other.rating == rating;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        author.hashCode ^
        imageUrl.hashCode ^
        rating.hashCode;
  }

  // Útil para criar cópias modificadas (ex: atualizar só a nota)
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
