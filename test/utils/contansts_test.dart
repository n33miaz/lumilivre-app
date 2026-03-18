import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/utils/constants.dart';

void main() {
  group('apiBaseUrl', () {
    test('deve apontar para HTTPS em produção', () {
      expect(apiBaseUrl, startsWith('https://'));
    });

    test('não deve ter barra final', () {
      expect(apiBaseUrl, isNot(endsWith('/')));
    });

    test('não deve conter porta no endereço de produção', () {
      final uri = Uri.parse(apiBaseUrl);
      expect(uri.hasPort, isFalse);
    });
  });

  group('LumiLivreTheme - cores', () {
    test('primary deve ser o roxo do brand (#762075)', () {
      expect(LumiLivreTheme.primary, const Color(0xFF762075));
    });
    test('label deve ser variação clara do primary', () {
      expect(LumiLivreTheme.label, const Color(0xFFC964C5));
    });
    test('lightBackground deve ser cinza claro', () {
      expect(LumiLivreTheme.lightBackground, const Color(0xFFF3F4F6));
    });
    test('darkBackground deve ser escuro', () {
      expect(LumiLivreTheme.darkBackground, const Color(0xFF111827));
    });
    test('lightCard deve ser branco', () {
      expect(LumiLivreTheme.lightCard, Colors.white);
    });
    test('darkCard deve ser cinza escuro', () {
      expect(LumiLivreTheme.darkCard, const Color(0xFF1F2937));
    });
    test('darkText deve ser branco', () {
      expect(LumiLivreTheme.darkText, Colors.white);
    });
  });

  group('LumiLivreTheme - lightTheme', () {
    final theme = LumiLivreTheme.lightTheme;
    test('deve ter brightness light', () {
      expect(theme.brightness, Brightness.light);
    });
    test('deve usar primary como primaryColor', () {
      expect(theme.primaryColor, LumiLivreTheme.primary);
    });
    test('deve usar lightBackground como scaffold', () {
      expect(theme.scaffoldBackgroundColor, LumiLivreTheme.lightBackground);
    });
    test('deve usar lightCard como cardColor', () {
      expect(theme.cardColor, LumiLivreTheme.lightCard);
    });
    test('colorScheme deve ter primary correto', () {
      expect(theme.colorScheme.primary, LumiLivreTheme.primary);
    });
    test('colorScheme brightness light', () {
      expect(theme.colorScheme.brightness, Brightness.light);
    });
    test('elevatedButtonTheme deve estar configurado', () {
      expect(theme.elevatedButtonTheme.style, isNotNull);
    });
    test('inputDecorationTheme deve ter border arredondada', () {
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    });
  });

  group('LumiLivreTheme - darkTheme', () {
    final theme = LumiLivreTheme.darkTheme;
    test('deve ter brightness dark', () {
      expect(theme.brightness, Brightness.dark);
    });
    test('deve usar primary como primaryColor', () {
      expect(theme.primaryColor, LumiLivreTheme.primary);
    });
    test('deve usar darkBackground como scaffold', () {
      expect(theme.scaffoldBackgroundColor, LumiLivreTheme.darkBackground);
    });
    test('deve usar darkCard como cardColor', () {
      expect(theme.cardColor, LumiLivreTheme.darkCard);
    });
    test('colorScheme brightness dark', () {
      expect(theme.colorScheme.brightness, Brightness.dark);
    });
    test('inputDecorationTheme deve ter fillColor darkCard', () {
      expect(theme.inputDecorationTheme.fillColor, LumiLivreTheme.darkCard);
    });
    test('inputDecorationTheme deve ter filled true', () {
      expect(theme.inputDecorationTheme.filled, isTrue);
    });
  });

  group('LumiLivreTheme - consistência', () {
    test('ambos os temas devem usar o mesmo primary', () {
      expect(LumiLivreTheme.lightTheme.primaryColor, LumiLivreTheme.darkTheme.primaryColor);
    });
    test('ambos devem ter elevatedButtonTheme configurado', () {
      expect(LumiLivreTheme.lightTheme.elevatedButtonTheme.style, isNotNull);
      expect(LumiLivreTheme.darkTheme.elevatedButtonTheme.style, isNotNull);
    });
    test('ambos devem ter inputDecorationTheme configurado', () {
      expect(LumiLivreTheme.lightTheme.inputDecorationTheme.border, isNotNull);
      expect(LumiLivreTheme.darkTheme.inputDecorationTheme.border, isNotNull);
    });
  });

  group('genreCardColors', () {
    test('deve ter pelo menos 8 cores', () {
      expect(LumiLivreTheme.genreCardColors.length, greaterThanOrEqualTo(8));
    });
    test('todas as cores devem ser opacas', () {
      for (final color in LumiLivreTheme.genreCardColors) {
        expect((color.a * 255).round(), 255, reason: 'Cor $color não é opaca');
      }
    });
    test('não deve conter cores duplicadas', () {
      final unique = LumiLivreTheme.genreCardColors.toSet();
      expect(unique.length, LumiLivreTheme.genreCardColors.length);
    });
  });
}
