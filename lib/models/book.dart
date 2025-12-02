import 'dart:convert';

class Book {
  final int id;
  final String title;
  final String author;
  final String imageUrl;
  final double rating;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.rating,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'author': author, 'imageUrl': imageUrl};
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id']?.toInt() ?? 0,
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      rating: (map['avaliacao'] as num?)?.toDouble() ?? 4.6, 
    );
  }

  String toJson() => json.encode(toMap());

  factory Book.fromJson(String source) => Book.fromMap(json.decode(source));
}
