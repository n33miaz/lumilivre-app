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

  group('secureMediaUrl', () {
    test('deve manter URL https intacta', () {
      expect(
        secureMediaUrl('https://cdn.exemplo.com/capa.jpg'),
        'https://cdn.exemplo.com/capa.jpg',
      );
    });

    test('deve subir http de host publico para https', () {
      expect(
        secureMediaUrl('http://cdn.exemplo.com/capa.jpg'),
        'https://cdn.exemplo.com/capa.jpg',
      );
    });

    test('deve recusar esquema que nao seja http(s)', () {
      expect(secureMediaUrl('data:image/png;base64,AAAA'), isNull);
      expect(secureMediaUrl('file:///sdcard/foto.jpg'), isNull);
      expect(secureMediaUrl('javascript:alert(1)'), isNull);
    });

    test('deve recusar valor sem esquema', () {
      expect(secureMediaUrl('www.exemplo.com/capa.jpg'), isNull);
      expect(secureMediaUrl('/storage/avatars/1.jpg'), isNull);
    });

    test('deve recusar null e vazio', () {
      expect(secureMediaUrl(null), isNull);
      expect(secureMediaUrl(''), isNull);
      expect(secureMediaUrl('   '), isNull);
    });

    test('deve normalizar esquema em caixa alta', () {
      expect(
        secureMediaUrl('HTTP://cdn.exemplo.com/capa.jpg'),
        'https://cdn.exemplo.com/capa.jpg',
      );
    });

    // A suite roda em debug, onde o cleartext para host local continua
    // liberado — é como o stack local serve as imagens.
    test('deve aceitar http de host local em debug', () {
      expect(
        secureMediaUrl('http://localhost:8080/storage/avatars/1.jpg'),
        'http://localhost:8080/storage/avatars/1.jpg',
      );
      expect(
        secureMediaUrl('http://10.0.2.2:8080/storage/avatars/1.jpg'),
        'http://10.0.2.2:8080/storage/avatars/1.jpg',
      );
      expect(
        secureMediaUrl('http://192.168.0.10:8080/storage/capa.jpg'),
        'http://192.168.0.10:8080/storage/capa.jpg',
      );
    });

    test('deve tratar 172.x fora da faixa privada como host publico', () {
      expect(
        secureMediaUrl('http://172.15.0.1/capa.jpg'),
        'https://172.15.0.1/capa.jpg',
      );
      expect(
        secureMediaUrl('http://172.20.0.1/capa.jpg'),
        'http://172.20.0.1/capa.jpg',
      );
    });
  });
}
