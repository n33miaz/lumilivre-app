import 'package:flutter/material.dart';

import 'package:lumilivre/utils/app_motion.dart';

/// Abre um diálogo com o comportamento único do app.
///
/// A decoração (cor, raio, elevação, tipografia do título) vem do
/// `dialogTheme` — nenhum diálogo precisa repetir isso. O que sobra para um
/// helper é o que o tema não alcança: a barreira e a animação de entrada.
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool dismissible = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: dismissible,
    // Zero quando o usuário pediu menos movimento; o `showDialog` cru não tem
    // como saber disso e sempre escala/desvanece.
    animationStyle: AppMotion.reduced(context)
        ? AnimationStyle.noAnimation
        : null,
    builder: builder,
  );
}

/// Abre um bottom sheet com a decoração e o comportamento únicos do app.
///
/// Antes o do mural passava cor de fundo e forma à mão e o do ranking não
/// passava nada — herdava o tom que o Material 3 calcula, que não é a carta do
/// app. Agora a cor e o raio vêm do `bottomSheetTheme` e o que este helper
/// garante é o resto do combinado: sheet rolável, respeitando entalhe de tela,
/// com o conteúdo cortado pelo canto arredondado.
Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Sem isto o conteúdo passa por cima do próprio canto arredondado.
    clipBehavior: Clip.antiAlias,
    sheetAnimationStyle: AppMotion.reduced(context)
        ? AnimationStyle.noAnimation
        : null,
    builder: builder,
  );
}

/// Título de um bottom sheet.
///
/// Lê a tipografia do título de diálogo de propósito: diálogo e sheet são a
/// mesma família de superfície, e cada um escrevia o seu `fontSize`/`bold` à mão
/// — o do ranking em 20, o do mural em 20, o `AlertDialog` no que o Material
/// desse. Se um dia o título do modal mudar, muda num lugar.
class AppSheetTitle extends StatelessWidget {
  const AppSheetTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).dialogTheme.titleTextStyle);
  }
}

/// Alça de arrastar do bottom sheet.
///
/// Existia desenhada à mão dentro do mural, com `Colors.grey.shade400` cravado —
/// e não existia no sheet do ranking, que abria sem nenhuma pista de que dava
/// para arrastar.
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
