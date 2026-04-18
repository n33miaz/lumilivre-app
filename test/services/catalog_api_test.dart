import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/services/catalog_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CatalogApi', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'getCatalogLocal deve retornar null quando cache nao existe',
      () async {
        final catalog = await CatalogApi().getCatalogLocal();

        expect(catalog, isNull);
      },
    );

    test('getCatalogLocal deve parsear cache valido', () async {
      SharedPreferences.setMockInitialValues({
        'catalog_cache_v1': '''
          [
            {
              "nome": "Ficcao",
              "livros": [
                {
                  "id": 1,
                  "titulo": "Duna",
                  "autor": "Frank Herbert",
                  "imagem": "http://example.com/duna.jpg",
                  "avaliacao": 4.8
                }
              ]
            }
          ]
        ''',
      });

      final catalog = await CatalogApi().getCatalogLocal();

      expect(catalog, isNotNull);
      expect(catalog!.keys, contains('Ficcao'));
      expect(catalog['Ficcao']!.single.title, 'Duna');
      expect(
        catalog['Ficcao']!.single.imageUrl,
        'https://example.com/duna.jpg',
      );
    });

    test('getCatalogLocal deve retornar null para cache invalido', () async {
      SharedPreferences.setMockInitialValues({
        'catalog_cache_v1': '{json invalido',
      });

      final catalog = await CatalogApi().getCatalogLocal();

      expect(catalog, isNull);
    });
  });
}
