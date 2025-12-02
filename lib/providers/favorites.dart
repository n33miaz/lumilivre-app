import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';

class FavoritesProvider with ChangeNotifier {
  List<Book> _favoriteBooks = [];

  List<Book> get favoriteBooks => _favoriteBooks;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? favoritesJson = prefs.getStringList('favoriteBooks');

    if (favoritesJson != null) {
      _favoriteBooks = favoritesJson
          .map((item) => Book.fromJson(item))
          .toList();
      notifyListeners();
    }
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> favoritesJson = _favoriteBooks
        .map((book) => book.toJson())
        .toList();
    await prefs.setStringList('favoriteBooks', favoritesJson);
  }

  bool isFavorite(int bookId) {
    return _favoriteBooks.any((book) => book.id == bookId);
  }

  void toggleFavorite(Book book) {
    final isExist = _favoriteBooks.any((element) => element.id == book.id);

    if (isExist) {
      _favoriteBooks.removeWhere((element) => element.id == book.id);
    } else {
      _favoriteBooks.add(book);
    }

    _saveFavorites();
    notifyListeners();
  }
}
