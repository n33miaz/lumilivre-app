import 'package:flutter/material.dart';

import 'package:lumilivre/services/api_health.dart';

/// Liga o monitor de saúde da API e pede o aquecimento da instância nos dois
/// momentos em que ele muda alguma coisa.
///
/// **Abrir o app.** O cold start da instância leva minutos; começar a contá-los
/// no segundo em que o app abre é o que faz a espera terminar antes de a pessoa
/// chegar na tela que precisa de dado.
///
/// **Voltar do segundo plano.** É o caso que o dono viveu: o app ficou parado, a
/// instância dormiu, e ao voltar nada carregava. `resumed` é o único aviso que o
/// sistema dá de que aquele intervalo terminou.
///
/// Note que não há timer aqui. Quem decide se o ping vale a pena é
/// [ApiHealth.warmUp], que ignora o pedido quando o servidor respondeu há pouco
/// ou quando já existe tentativa em andamento — o app pode voltar do segundo
/// plano dez vezes em um minuto sem gerar dez requisições.
class ApiWarmUpObserver extends StatefulWidget {
  const ApiWarmUpObserver({super.key, required this.child});

  final Widget child;

  @override
  State<ApiWarmUpObserver> createState() => _ApiWarmUpObserverState();
}

class _ApiWarmUpObserverState extends State<ApiWarmUpObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Este é o único lugar que liga o monitor: fora do app rodando (testes de
    // unidade, por exemplo) ele não abre socket nem cria timer.
    ApiHealth.instance.enable();
    ApiHealth.instance.warmUp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ApiHealth.instance.warmUp();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
