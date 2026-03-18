import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/utils/parsers.dart';

void main() {
  group('parseDate', () {
    test('deve parsear List [year, month, day]', () {
      final result = parseDate([2025, 3, 15], fallback: () => DateTime(1900));
      expect(result, DateTime(2025, 3, 15));
    });

    test('deve parsear List com apenas [year]', () {
      final result = parseDate([2020], fallback: () => DateTime(1900));
      expect(result, DateTime(2020, 1, 1));
    });

    test('deve parsear List com [year, month]', () {
      final result = parseDate([2020, 6], fallback: () => DateTime(1900));
      expect(result, DateTime(2020, 6, 1));
    });

    test('deve parsear String ISO', () {
      final result = parseDate('2023-06-15', fallback: () => DateTime(1900));
      expect(result, DateTime(2023, 6, 15));
    });

    test('deve retornar fallback para null', () {
      final result = parseDate(null, fallback: () => DateTime(1900, 1, 1));
      expect(result, DateTime(1900, 1, 1));
    });

    test('deve retornar fallback para String inválida', () {
      final result = parseDate('lixo', fallback: () => DateTime(1900, 1, 1));
      expect(result, DateTime(1900, 1, 1));
    });

    test('deve retornar fallback para List vazia', () {
      final result = parseDate([], fallback: () => DateTime(1900, 1, 1));
      expect(result, DateTime(1900, 1, 1));
    });

    test('deve usar DateTime.now como fallback quando configurado', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final result = parseDate(null, fallback: DateTime.now);
      final after = DateTime.now().add(const Duration(seconds: 1));
      expect(result.isAfter(before), isTrue);
      expect(result.isBefore(after), isTrue);
    });
  });

  group('safeParseInt', () {
    test('deve retornar 0 para null', () {
      expect(safeParseInt(null), 0);
    });
    test('deve retornar int direto', () {
      expect(safeParseInt(42), 42);
    });
    test('deve converter double para int', () {
      expect(safeParseInt(5.7), 5);
    });
    test('deve converter String válida', () {
      expect(safeParseInt('10'), 10);
    });
    test('deve retornar 0 para String inválida', () {
      expect(safeParseInt('abc'), 0);
    });
    test('deve retornar 0 para bool', () {
      expect(safeParseInt(true), 0);
    });
  });

  group('safeParseDouble', () {
    test('deve retornar 0.0 para null', () {
      expect(safeParseDouble(null), 0.0);
    });
    test('deve retornar double direto', () {
      expect(safeParseDouble(4.8), 4.8);
    });
    test('deve converter int para double', () {
      expect(safeParseDouble(5), 5.0);
    });
    test('deve converter String com ponto', () {
      expect(safeParseDouble('4.5'), 4.5);
    });
    test('deve converter String com vírgula brasileira', () {
      expect(safeParseDouble('4,5'), 4.5);
    });
    test('deve retornar 0.0 para String inválida', () {
      expect(safeParseDouble('xyz'), 0.0);
    });
    test('deve retornar 0.0 para bool', () {
      expect(safeParseDouble(true), 0.0);
    });
  });
}
