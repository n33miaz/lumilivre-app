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

    /// O fill era exatamente `darkCard` — a mesma cor da carta e do diálogo.
    /// Resultado: dentro do diálogo de senha o campo não tinha borda visível nem
    /// fundo próprio, então não havia como saber onde clicar para digitar.
    test('campo preenchido deve destacar-se da carta', () {
      expect(theme.inputDecorationTheme.fillColor, isNotNull);
      expect(theme.inputDecorationTheme.fillColor, isNot(theme.cardColor));
    });
    test('inputDecorationTheme deve ter filled true', () {
      expect(theme.inputDecorationTheme.filled, isTrue);
    });

    /// A regra de tinta do tema escuro: `primary` do esquema é o tom claro da
    /// marca, porque #762075 sobre #111827 não se lê. Quem quiser a superfície
    /// roxa usa `primaryColor`, que continua sendo o roxo.
    test('colorScheme.primary deve ser a tinta clara da marca', () {
      expect(theme.colorScheme.primary, LumiLivreTheme.label);
      expect(theme.colorScheme.primary, isNot(LumiLivreTheme.primary));
      expect(theme.primaryColor, LumiLivreTheme.primary);
    });
  });

  group('LumiLivreTheme - consistência', () {
    test('ambos os temas devem usar o mesmo primary', () {
      expect(
        LumiLivreTheme.lightTheme.primaryColor,
        LumiLivreTheme.darkTheme.primaryColor,
      );
    });
    test('ambos devem ter elevatedButtonTheme configurado', () {
      expect(LumiLivreTheme.lightTheme.elevatedButtonTheme.style, isNotNull);
      expect(LumiLivreTheme.darkTheme.elevatedButtonTheme.style, isNotNull);
    });
    test('ambos devem ter inputDecorationTheme configurado', () {
      expect(LumiLivreTheme.lightTheme.inputDecorationTheme.border, isNotNull);
      expect(LumiLivreTheme.darkTheme.inputDecorationTheme.border, isNotNull);
    });

    /// Diálogo e bottom sheet são a mesma família de superfície. Antes cada
    /// modal escolhia o seu raio (16 no tour, 20 nos sheets, 28 herdado do
    /// Material 3 nos diálogos de senha) e a diferença aparecia no mesmo fluxo.
    test('modal deve ter um raio só, em diálogo e em sheet', () {
      for (final theme in [
        LumiLivreTheme.lightTheme,
        LumiLivreTheme.darkTheme,
      ]) {
        final dialogShape = theme.dialogTheme.shape as RoundedRectangleBorder;
        final sheetShape =
            theme.bottomSheetTheme.shape as RoundedRectangleBorder;

        expect(
          dialogShape.borderRadius,
          BorderRadius.circular(LumiLivreTheme.radiusModal),
        );
        expect(
          sheetShape.borderRadius,
          const BorderRadius.vertical(
            top: Radius.circular(LumiLivreTheme.radiusModal),
          ),
        );
      }
    });

    test('modal deve usar a cor de carta nos dois temas', () {
      expect(
        LumiLivreTheme.lightTheme.dialogTheme.backgroundColor,
        LumiLivreTheme.lightCard,
      );
      expect(
        LumiLivreTheme.darkTheme.dialogTheme.backgroundColor,
        LumiLivreTheme.darkCard,
      );
      expect(
        LumiLivreTheme.darkTheme.bottomSheetTheme.modalBackgroundColor,
        LumiLivreTheme.darkCard,
      );
    });
  });

  /// Tinta de status: o mesmo verde/laranja/vermelho para todo o app, mais claro
  /// no tema escuro porque ali ele é tinta sobre uma carta escura.
  group('LumiStatusColors', () {
    testWidgets('deve clarear a tinta no tema escuro', (tester) async {
      LumiStatusColors? light;
      LumiStatusColors? dark;

      // `Theme` e não `MaterialApp(theme:)`: o `MaterialApp` interpola a troca
      // de tema em 200 ms, então no primeiro quadro o brilho ainda é o antigo e
      // o teste leria a paleta errada.
      for (final theme in [
        LumiLivreTheme.lightTheme,
        LumiLivreTheme.darkTheme,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Theme(
              data: theme,
              child: Builder(
                builder: (context) {
                  final resolved = LumiStatusColors.of(context);
                  if (theme.brightness == Brightness.dark) {
                    dark = resolved;
                  } else {
                    light = resolved;
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );
      }

      expect(light, isNotNull);
      expect(dark, isNotNull);
      expect(dark!.success, isNot(light!.success));
      expect(dark!.danger, isNot(light!.danger));
      // Clarear é medido, não descrito: no escuro a tinta precisa ter mais
      // luminância que a da carta, senão volta a ser cinza sobre cinza.
      expect(
        dark!.success.computeLuminance(),
        greaterThan(light!.success.computeLuminance()),
      );
      expect(
        dark!.danger.computeLuminance(),
        greaterThan(light!.danger.computeLuminance()),
      );
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
