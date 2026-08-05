import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/utils/app_motion.dart';

/// Acessibilidade de movimento não é observável olhando a tela: se a saída
/// deixar de existir, nada quebra e ninguém vê. Estes testes prendem o
/// comportamento de `disableAnimations` — o equivalente Flutter do
/// `prefers-reduced-motion`.
void main() {
  /// Monta uma tela com o sinal do sistema ligado ou desligado e devolve o
  /// contexto de dentro dela.
  Future<BuildContext> pumpWithAnimations(
    WidgetTester tester, {
    required bool disableAnimations,
  }) async {
    late BuildContext captured;

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(disableAnimations: disableAnimations),
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              captured = context;
              return const Scaffold(body: SizedBox.shrink());
            },
          ),
        ),
      ),
    );

    return captured;
  }

  group('AppMotion', () {
    testWidgets('deve manter a duração quando há animação', (tester) async {
      final context = await pumpWithAnimations(
        tester,
        disableAnimations: false,
      );

      expect(AppMotion.reduced(context), isFalse);
      expect(AppMotion.of(context, AppMotion.page), AppMotion.page);
      expect(AppMotion.of(context, AppMotion.micro), AppMotion.micro);
    });

    testWidgets('deve zerar a duração quando o sistema pede menos movimento', (
      tester,
    ) async {
      final context = await pumpWithAnimations(tester, disableAnimations: true);

      expect(AppMotion.reduced(context), isTrue);
      expect(AppMotion.of(context, AppMotion.page), Duration.zero);
      expect(AppMotion.of(context, AppMotion.quick), Duration.zero);
      expect(AppMotion.of(context, AppMotion.normal), Duration.zero);
      expect(AppMotion.of(context, AppMotion.micro), Duration.zero);
    });

    test('os degraus devem estar em ordem crescente', () {
      expect(AppMotion.micro, lessThan(AppMotion.quick));
      expect(AppMotion.quick, lessThan(AppMotion.normal));
      expect(AppMotion.normal, lessThan(AppMotion.page));
    });
  });

  group('AppPageRoute', () {
    testWidgets('deve usar a duração de página do app', (tester) async {
      final context = await pumpWithAnimations(
        tester,
        disableAnimations: false,
      );

      final route = AppPageRoute<void>(
        context: context,
        builder: (_) => const SizedBox.shrink(),
      );

      expect(route.transitionDuration, AppMotion.page);
      expect(route.reverseTransitionDuration, AppMotion.page);
    });

    testWidgets('deve abrir sem transição quando pedem menos movimento', (
      tester,
    ) async {
      final context = await pumpWithAnimations(tester, disableAnimations: true);

      final route = AppPageRoute<void>(
        context: context,
        builder: (_) => const SizedBox.shrink(),
      );

      expect(route.transitionDuration, Duration.zero);
      expect(route.reverseTransitionDuration, Duration.zero);
    });

    /// A tela que entra não pode aparecer deslocada: se o `SlideTransition`
    /// ficasse na árvore com duração zero, a página nasceria 4% abaixo do lugar.
    testWidgets('sem animação a página não deve nascer deslocada', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).push(
                      AppPageRoute<void>(
                        context: context,
                        builder: (_) => const Scaffold(
                          body: Center(child: Text('destino')),
                        ),
                      ),
                    ),
                    child: const Text('abrir'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pump();

      expect(find.text('destino'), findsOneWidget);
      expect(find.byType(SlideTransition), findsNothing);
      expect(find.byType(FadeTransition), findsNothing);
    });
  });
}
