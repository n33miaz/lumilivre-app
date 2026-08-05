import 'package:flutter/material.dart';

/// Durações e curvas de transição do app, num lugar só.
///
/// O app tinha 150, 200, 250, 300, 600 e 800 ms convivendo, e sete curvas
/// diferentes (`ease`, `easeIn`, `easeOut`, `easeInOut`, `easeOutCubic`,
/// `easeOutBack`, `easeInOutBack`). Cada animação isolada era boa; juntas
/// faziam o app parecer montado por pessoas diferentes. Quatro degraus bastam,
/// e o critério é o tamanho do que se move — não a tela onde acontece.
///
/// As duas curvas com sobrepasso (`...Back`) saíram: o salto que elas dão é
/// justamente o "pulo" que se enxerga num aparelho lento.
abstract final class AppMotion {
  /// Resposta ao dedo: cartão que afunda, ícone que troca.
  static const Duration micro = Duration(milliseconds: 150);

  /// Realce que muda de cor, borda ou sombra sem sair do lugar.
  static const Duration quick = Duration(milliseconds: 200);

  /// Conteúdo que entra no lugar de outro.
  static const Duration normal = Duration(milliseconds: 250);

  /// Rota, aba, cabeçalho — o que atravessa a tela.
  static const Duration page = Duration(milliseconds: 300);

  /// Entrada: rápido no começo, freando no fim.
  static const Curve enter = Curves.easeOutCubic;

  /// Ida e volta pelo mesmo caminho (aba que desliza, alinhamento que alterna).
  static const Curve inOut = Curves.easeInOut;

  /// O usuário pediu ao sistema para reduzir animação.
  ///
  /// É o equivalente Flutter do `prefers-reduced-motion` do web: no Android vem
  /// de "escala de animação de transição" zerada nas opções do desenvolvedor ou
  /// da acessibilidade. O framework já encurta todo `AnimationController` para
  /// 5% da duração nesse caso, o que ainda deixa um quadro de movimento e ainda
  /// paga a construção da árvore de transição; onde este sinal é consultado, a
  /// animação simplesmente não existe.
  static bool reduced(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  /// [duration], ou zero quando o usuário pediu para reduzir animação.
  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}

/// Rota padrão de tela empilhada.
///
/// Havia três transições para a mesma ação de empilhar uma tela: deslizar da
/// direita (Configurações), subir a tela inteira de baixo (categoria) e um
/// `MaterialPageRoute` cru (login, busca, esteira) — mais um quarto caso com
/// desvanecimento (ficha do livro). Direção diferente para a mesma ação é o que
/// faz a navegação parecer sem plano, então aqui existe **uma**: desvanecer
/// subindo um pouco, que é curta o bastante para não atrapalhar e não depende
/// de largura de tela.
///
/// Só a página que entra se move. Animar as duas custa o dobro de composição e
/// não se percebe em 300 ms.
class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({required BuildContext context, required WidgetBuilder builder})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionDuration: AppMotion.of(context, AppMotion.page),
        reverseTransitionDuration: AppMotion.of(context, AppMotion.page),
        transitionsBuilder: _fadeUp,
      );

  static Widget _fadeUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (AppMotion.reduced(context)) {
      return child;
    }

    final position = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).chain(CurveTween(curve: AppMotion.enter)).animate(animation);

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: position, child: child),
    );
  }
}
