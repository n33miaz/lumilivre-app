import 'package:flutter/material.dart';

/// Tom do aviso. Só três, porque só existem três coisas a dizer: deu certo,
/// não deu, e "estou fazendo".
enum ToastTone { neutral, success, error }

/// Ponto único de aviso transitório do app.
///
/// O app já avisava por `ScaffoldMessenger`/`SnackBar` — o problema nunca foi o
/// mecanismo, foi cada uma das doze chamadas escolher sozinha cor, duração e
/// nada de acessibilidade. Isto não é um segundo sistema de notificação: é o
/// mesmo `SnackBar`, montado num lugar só.
///
/// Duas coisas que ninguém acertava repetindo o código à mão:
///
/// - **Tempo de leitura.** O padrão do Material são 4 s, o que basta para
///   "Senha alterada" e não para uma frase de política de empréstimo. E o
///   `ScaffoldMessenger` não pausa a contagem quando há leitor de tela: o timer
///   começa junto com a locução, então quem ouve tem menos tempo do que quem lê.
/// - **Fila.** `showSnackBar` empilha. Quando o app avisa "enviando..." e depois
///   "enviado", o segundo aviso esperava o primeiro terminar — o resultado
///   chegava segundos depois de já ter acontecido. Aqui o novo substitui o
///   anterior.
///
/// O anúncio em leitor de tela não precisa de `SemanticsService.announce`: o
/// `SnackBar` do Flutter já se envolve em `Semantics(liveRegion: true)`, e um
/// announce manual faria o TalkBack falar a mesma frase duas vezes.
///
/// Uso: pegue a instância **antes** do `await` e chame depois, para não precisar
/// de `BuildContext` do outro lado do gap assíncrono.
///
/// ```dart
/// final toast = AppToast.of(context);
/// final ok = await api.algo();
/// toast.success(l10n.algoFeito);
/// ```
@immutable
class AppToast {
  const AppToast._(this._messenger, this._screenReaderOn);

  final ScaffoldMessengerState _messenger;
  final bool _screenReaderOn;

  factory AppToast.of(BuildContext context) => AppToast._(
    ScaffoldMessenger.of(context),
    MediaQuery.accessibleNavigationOf(context),
  );

  void info(String message) => _show(message, ToastTone.neutral);

  void success(String message) => _show(message, ToastTone.success);

  void error(String message) => _show(message, ToastTone.error);

  void _show(String message, ToastTone tone) {
    if (message.trim().isEmpty) {
      return;
    }

    _messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _backgroundFor(tone),
          duration: _readingTime(message),
        ),
      );
  }

  /// Cores como já estavam nas chamadas espalhadas — trazidas para um lugar só
  /// para que trocar a paleta seja uma edição, não doze.
  static Color? _backgroundFor(ToastTone tone) => switch (tone) {
    ToastTone.neutral => null,
    ToastTone.success => Colors.green.shade700,
    ToastTone.error => Colors.redAccent,
  };

  /// ~4 s para frase curta, até 10 s para a mais longa (teto do Material), e mais
  /// folga quando há leitor de tela, que gasta o tempo falando.
  Duration _readingTime(String message) {
    final words = message.trim().split(RegExp(r'\s+')).length;
    final seconds = (2 + words * 0.4).ceil().clamp(4, 10);
    return Duration(seconds: _screenReaderOn ? seconds * 2 : seconds);
  }
}
