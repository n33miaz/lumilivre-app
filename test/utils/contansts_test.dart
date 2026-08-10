import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/utils/constants.dart';
import 'package:lumilivre/widgets/section_rule.dart';

/// Razão de contraste WCAG entre duas cores opacas.
///
/// `computeLuminance` já é a luminância relativa da norma; o que falta é a
/// razão, que é o número comparável com o mínimo AA.
double _contrastRatio(Color a, Color b) {
  final first = a.computeLuminance();
  final second = b.computeLuminance();
  final lighter = first > second ? first : second;
  final darker = first > second ? second : first;
  return (lighter + 0.05) / (darker + 0.05);
}

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
    test('lightBackground deve ser o papel (#F8F5EE)', () {
      expect(LumiLivreTheme.lightBackground, const Color(0xFFF8F5EE));
    });
    test('darkBackground deve ser a tinta (#0B0810)', () {
      expect(LumiLivreTheme.darkBackground, const Color(0xFF0B0810));
    });
    test('lightCard deve ser a face da ficha (#FFFDF9)', () {
      expect(LumiLivreTheme.lightCard, const Color(0xFFFFFDF9));
    });
    test('darkCard deve ser a ficha no escuro (#13101B)', () {
      expect(LumiLivreTheme.darkCard, const Color(0xFF13101B));
    });
    test('darkText deve ser a tinta clara (#F5F1E8)', () {
      expect(LumiLivreTheme.darkText, const Color(0xFFF5F1E8));
    });

    /// O neutro do app deixou de ser cinza azulado. É isso que faz o roxo da
    /// marca ler como cor em vez de mais um degrau do próprio fundo, e é a
    /// única coisa que precisa continuar valendo se alguém reafinar a paleta:
    /// no papel o vermelho vem antes do azul; na tinta escura, o inverso (ela é
    /// arroxeada de propósito, é a família do #762075).
    test('o neutro claro é quente, e não cinza azulado', () {
      for (final color in [
        LumiLivreTheme.lightBackground,
        LumiLivreTheme.lightCard,
        LumiLivreTheme.lightText,
      ]) {
        expect(
          color.r,
          greaterThan(color.b),
          reason: '$color puxa para o azul',
        );
      }
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

  /// A paleta é quente, o que não a dispensa de nada: o valor de um neutro é
  /// justamente quanto texto ele aguenta por cima. Cada par abaixo aparece em
  /// tela em corpo pequeno, então o piso é o AA de texto normal (4,5:1) — e não
  /// o de texto grande.
  group('LumiLivreTheme - contraste AA', () {
    for (final entry in {
      'claro': LumiLivreTheme.lightTheme,
      'escuro': LumiLivreTheme.darkTheme,
    }.entries) {
      final name = entry.key;
      final theme = entry.value;
      final scheme = theme.colorScheme;
      final screen = theme.scaffoldBackgroundColor;

      test('tema $name: texto e tinta passam AA sobre papel e carta', () {
        final pairs = <String, List<Color>>{
          'texto sobre a carta': [scheme.onSurface, scheme.surface],
          'texto sobre a tela': [scheme.onSurface, screen],
          'texto secundário sobre a carta': [
            scheme.onSurfaceVariant,
            scheme.surface,
          ],
          'texto secundário sobre a tela': [scheme.onSurfaceVariant, screen],
          // Trilho de abas, pastilha de posição, botão indisponível: é o degrau
          // mais escuro que ainda recebe texto.
          'texto secundário sobre a faixa recuada': [
            scheme.onSurfaceVariant,
            scheme.surfaceContainerHighest,
          ],
          'tinta da marca sobre a carta': [scheme.primary, scheme.surface],
          'faixa de aviso do sistema': [
            scheme.onInverseSurface,
            scheme.inverseSurface,
          ],
          'tinta sobre o roxo da marca': [
            LumiLivreTheme.onBrand,
            theme.primaryColor,
          ],
        };

        pairs.forEach((label, colors) {
          expect(
            _contrastRatio(colors[0], colors[1]),
            greaterThanOrEqualTo(4.5),
            reason: '$label falha AA no tema $name',
          );
        });
      });
    }

    /// O selo do empréstimo é a carta com 10% da cor de status por cima, e é
    /// onde a tinta de status aparece em corpo 12. Medido ali, e não sobre a
    /// carta limpa, porque é ali que ele é lido.
    testWidgets('a tinta de status passa AA sobre o próprio selo', (
      tester,
    ) async {
      for (final theme in [
        LumiLivreTheme.lightTheme,
        LumiLivreTheme.darkTheme,
      ]) {
        late LumiStatusColors status;
        await tester.pumpWidget(
          MaterialApp(
            home: Theme(
              data: theme,
              child: Builder(
                builder: (context) {
                  status = LumiStatusColors.of(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        );

        final card = theme.colorScheme.surface;
        for (final ink in [status.success, status.warning, status.danger]) {
          final badge = Color.alphaBlend(ink.withValues(alpha: 0.1), card);
          expect(
            _contrastRatio(ink, badge),
            greaterThanOrEqualTo(4.5),
            reason: '$ink falha AA sobre o selo de status',
          );
        }
      }
    });
  });

  /// Onde havia sombra agora há filete, e filete é forma: a `AppBar` desenha
  /// uma borda só na base, a carta desenha um contorno inteiro e o modal
  /// desenha o dele com raio. Borda não-uniforme como forma de `Material` é o
  /// tipo de coisa que passa na análise e falha ao pintar — aqui ela pinta, nos
  /// dois brilhos.
  testWidgets('as superfícies do tema pintam nos dois brilhos', (tester) async {
    for (final theme in [LumiLivreTheme.lightTheme, LumiLivreTheme.darkTheme]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            appBar: AppBar(title: const Text('ficha')),
            body: const Column(
              children: [
                Card(child: SizedBox(height: 40, width: 40)),
                Divider(),
                SectionRule(child: Text('bloco')),
                SectionRule.below(child: Text('cabeçalho')),
                // Linha de registro: etiqueta e valor alinhados pela base. A
                // etiqueta embrulha o texto em `Semantics` para o leitor de
                // tela não soletrar a caixa alta, e quem alinha pela base
                // precisa que esse embrulho ainda entregue uma linha de base.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [CotaLabel('cota'), Text('valor')],
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    }
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
