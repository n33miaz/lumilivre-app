import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumilivre/widgets/app_toast.dart';

void main() {
  /// Monta uma tela com um botão que dispara o toast, para exercitar o
  /// `ScaffoldMessenger` de verdade em vez de mockar o mecanismo.
  Future<void> pumpHost(
    WidgetTester tester,
    void Function(AppToast toast) onTap, {
    bool accessibleNavigation = false,
  }) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(accessibleNavigation: accessibleNavigation),
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => onTap(AppToast.of(context)),
                child: const Text('disparar'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('deve exibir a mensagem num SnackBar', (tester) async {
    await pumpHost(tester, (toast) => toast.success('Solicitação enviada.'));

    await tester.tap(find.text('disparar'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Solicitação enviada.'), findsOneWidget);
  });

  testWidgets('deve ignorar mensagem vazia', (tester) async {
    await pumpHost(tester, (toast) => toast.error('   '));

    await tester.tap(find.text('disparar'));
    await tester.pump();

    expect(find.byType(SnackBar), findsNothing);
  });

  /// `showSnackBar` empilha: o segundo aviso esperava o primeiro terminar, e o
  /// resultado de uma ação chegava segundos depois de ela ter acontecido.
  testWidgets('aviso novo deve substituir o anterior, nao enfileirar', (
    tester,
  ) async {
    late AppToast captured;
    await pumpHost(tester, (toast) => captured = toast);

    await tester.tap(find.text('disparar'));
    await tester.pump();

    captured.info('Enviando foto...');
    await tester.pump();
    expect(find.text('Enviando foto...'), findsOneWidget);

    captured.success('Foto atualizada.');
    await tester.pumpAndSettle();

    expect(find.text('Enviando foto...'), findsNothing);
    expect(find.text('Foto atualizada.'), findsOneWidget);
  });

  /// O `SnackBar` do Flutter já se envolve em `Semantics(liveRegion: true)`, que
  /// é o que faz o leitor de tela anunciar o aviso sozinho — por isso o helper
  /// não chama `SemanticsService.announce` (falaria duas vezes).
  testWidgets('mensagem deve ser anunciavel por leitor de tela', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpHost(tester, (toast) => toast.error('Não foi possível entrar.'));

    await tester.tap(find.text('disparar'));
    await tester.pump();

    expect(
      tester.getSemantics(find.text('Não foi possível entrar.')),
      isSemantics(label: 'Não foi possível entrar.', isLiveRegion: true),
    );
    handle.dispose();
  });

  testWidgets('frase longa deve ficar mais tempo na tela que frase curta', (
    tester,
  ) async {
    late AppToast captured;
    await pumpHost(tester, (toast) => captured = toast);
    await tester.tap(find.text('disparar'));
    await tester.pump();

    captured.info('Pronto.');
    await tester.pump();
    final short = tester.widget<SnackBar>(find.byType(SnackBar)).duration;

    captured.info(
      'Você está com uma restrição na conta e volta a solicitar livros em '
      '10 de agosto de 2026. Até lá continue explorando o catálogo.',
    );
    await tester.pumpAndSettle();
    final long = tester.widget<SnackBar>(find.byType(SnackBar)).duration;

    expect(short, const Duration(seconds: 4));
    expect(long, greaterThan(short));
  });

  /// O `ScaffoldMessenger` não pausa a contagem quando há leitor de tela: o timer
  /// começa junto com a locução, então quem ouve tem menos tempo do que quem lê.
  testWidgets('leitor de tela ligado deve render mais tempo de leitura', (
    tester,
  ) async {
    late AppToast normal;
    await pumpHost(tester, (toast) => normal = toast);
    await tester.tap(find.text('disparar'));
    await tester.pump();
    normal.info('Foto atualizada.');
    await tester.pump();
    final withoutReader = tester
        .widget<SnackBar>(find.byType(SnackBar))
        .duration;

    late AppToast assisted;
    await pumpHost(
      tester,
      (toast) => assisted = toast,
      accessibleNavigation: true,
    );
    await tester.tap(find.text('disparar'));
    await tester.pump();
    assisted.info('Foto atualizada.');
    await tester.pump();
    final withReader = tester.widget<SnackBar>(find.byType(SnackBar)).duration;

    expect(withReader, greaterThan(withoutReader));
  });
}
