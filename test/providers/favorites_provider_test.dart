import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lumilivre/providers/favorites.dart';
import 'package:lumilivre/models/book.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoritesProvider', () {
    late FavoritesProvider provider;

    const bookA = Book(
      id: 1,
      title: 'Livro A',
      author: 'Autor A',
      imageUrl: '',
      rating: 4.0,
    );
    const bookB = Book(
      id: 2,
      title: 'Livro B',
      author: 'Autor B',
      imageUrl: '',
      rating: 3.5,
    );
    const bookADuplicate = Book(
      id: 1,
      title: 'Livro A',
      author: 'Autor A',
      imageUrl: '',
      rating: 4.0,
    );

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = FavoritesProvider();
    });

    group('estado inicial', () {
      test('deve iniciar com lista de favoritos vazia', () {
        expect(provider.favoriteBooks, isEmpty);
      });

      test('isFavorite deve retornar false para qualquer id', () {
        expect(provider.isFavorite(1), isFalse);
        expect(provider.isFavorite(999), isFalse);
      });
    });

    group('toggleFavorite - adicionar', () {
      test('deve adicionar livro à lista de favoritos', () {
        provider.toggleFavorite(bookA);
        expect(provider.favoriteBooks, hasLength(1));
        expect(provider.isFavorite(bookA.id), isTrue);
      });

      test('deve adicionar múltiplos livros diferentes', () {
        provider.toggleFavorite(bookA);
        provider.toggleFavorite(bookB);
        expect(provider.favoriteBooks, hasLength(2));
      });

      test('deve notificar listeners ao adicionar', () {
        int notifyCount = 0;
        provider.addListener(() => notifyCount++);
        provider.toggleFavorite(bookA);
        expect(notifyCount, 1);
      });
    });

    group('toggleFavorite - remover', () {
      test('deve remover livro já favoritado (toggle off)', () {
        provider.toggleFavorite(bookA);
        provider.toggleFavorite(bookA);
        expect(provider.isFavorite(bookA.id), isFalse);
        expect(provider.favoriteBooks, isEmpty);
      });

      test('deve remover por id mesmo com instância diferente', () {
        provider.toggleFavorite(bookA);
        provider.toggleFavorite(bookADuplicate);
        expect(provider.isFavorite(1), isFalse);
      });

      test('deve manter outros livros ao remover um', () {
        provider.toggleFavorite(bookA);
        provider.toggleFavorite(bookB);
        provider.toggleFavorite(bookA);
        expect(provider.favoriteBooks, hasLength(1));
        expect(provider.isFavorite(bookB.id), isTrue);
      });
    });

    group('cenários compostos', () {
      test('toggle rápido (add-remove-add) deve resultar em favoritado', () {
        provider.toggleFavorite(bookA);
        provider.toggleFavorite(bookA);
        provider.toggleFavorite(bookA);
        expect(provider.isFavorite(bookA.id), isTrue);
        expect(provider.favoriteBooks, hasLength(1));
      });
    });
  });
}
