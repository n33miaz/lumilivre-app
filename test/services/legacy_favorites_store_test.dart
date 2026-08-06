import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lumilivre/models/book.dart';
import 'package:lumilivre/services/legacy_favorites_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const bookA = Book(
    id: 'aaaaaaaa-0000-4000-8000-000000000001',
    title: 'Livro A',
    author: 'Autor A',
    imageUrl: '',
    rating: 4,
  );
  const bookB = Book(
    id: 'bbbbbbbb-0000-4000-8000-000000000002',
    title: 'Livro B',
    author: 'Autor B',
    imageUrl: '',
    rating: 3,
  );

  late LegacyFavoritesStore store;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = LegacyFavoritesStore();
  });

  test('aparelho sem lista antiga não tem nada a migrar', () async {
    expect(await store.pending(), isEmpty);
    expect(await store.isDone(), isFalse);
  });

  test('lê a lista como as versões antigas gravavam', () async {
    SharedPreferences.setMockInitialValues({
      LegacyFavoritesStore.favoritesKey: [bookA.toJson(), bookB.toJson()],
    });

    final pending = await store.pending();

    expect(pending.map((book) => book.id), [bookA.id, bookB.id]);
  });

  /// Um item ilegível travaria a migração para sempre: ele não sobe, então a fila
  /// nunca esvaziaria e a chave antiga nunca seria fechada.
  test('descarta entrada corrompida, item sem id e id repetido', () async {
    SharedPreferences.setMockInitialValues({
      LegacyFavoritesStore.favoritesKey: [
        bookA.toJson(),
        '{isso nao e json}',
        '{"id":null,"title":"Sem id"}',
        bookA.toJson(),
      ],
    });

    expect((await store.pending()).map((book) => book.id), [bookA.id]);
  });

  test('drop tira só o livro que subiu', () async {
    SharedPreferences.setMockInitialValues({
      LegacyFavoritesStore.favoritesKey: [bookA.toJson(), bookB.toJson()],
    });

    await store.drop(bookA.id);

    expect((await store.pending()).map((book) => book.id), [bookB.id]);
    expect(
      await store.isDone(),
      isFalse,
      reason: 'meia migração não é migração feita',
    );
  });

  test('finish apaga a chave antiga e fecha a migração', () async {
    SharedPreferences.setMockInitialValues({
      LegacyFavoritesStore.favoritesKey: [bookA.toJson()],
    });

    await store.finish();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(LegacyFavoritesStore.favoritesKey), isNull);
    expect(await store.isDone(), isTrue);
  });
}
