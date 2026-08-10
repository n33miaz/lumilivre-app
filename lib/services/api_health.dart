import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';
import 'api_error.dart';
import 'request_context.dart';

/// O que o app sabe, agora, sobre a API do outro lado.
///
/// Note que **nenhum destes estados fala do aparelho**. "Sem internet" é outra
/// pergunta, respondida por outro sensor (`connectivity_plus`), e confundir as
/// duas foi o que deixou o usuário sem explicação: a rede do celular estava
/// perfeita, o servidor é que estava dormindo.
enum ApiHealthStatus {
  /// Ainda não perguntamos nada a ninguém.
  unknown,

  /// Alguém atendeu — mesmo que tenha atendido para recusar.
  reachable,

  /// Ninguém atendeu e ainda estamos dentro do tempo em que faz sentido
  /// esperar: a instância hiberna e volta sozinha.
  waking,

  /// Passou do tempo de subida e continua sem resposta. Aqui já não é
  /// hibernação, é indisponibilidade — e insistir sozinho vira polling.
  unreachable,
}

/// Monitor de saúde da API: descobre que o servidor não responde, espera por ele
/// e avisa quando ele volta.
///
/// **Por que isto existe.** A API roda em instância que hiberna quando fica
/// ociosa; medimos ~190 s entre o primeiro pacote e a porta atender. Nesse
/// intervalo toda chamada do app estoura o prazo e o usuário via a mesma tela de
/// carregamento eterna, ou o mesmo "não foi possível conectar" que ele lê como
/// "meu celular está sem internet". O que faltava não era prazo maior — era
/// alguém dizendo *o que* está acontecendo e *quanto* falta.
///
/// **Por que não é polling.** O laço de tentativas só existe enquanto o estado é
/// [ApiHealthStatus.waking], com espera crescente entre elas e com teto: passado
/// [_recoveryBudget] sem resposta, o monitor desiste e fica calado até alguém
/// pedir de novo. Fora disso o único tráfego é o ping de aquecimento, disparado
/// por abertura do app (e por volta do segundo plano), com deduplicação — nunca
/// em intervalo fixo, que é o que gastaria bateria e dado do aluno.
///
/// **Por que precisa ser ligado.** Enquanto [enable] não é chamado, esta classe
/// não instala gancho, não abre socket e não cria timer. É o que mantém os
/// testes de unidade — que classificam erro de rede aos montes — livres de
/// requisição de verdade e de timer pendente.
class ApiHealth extends ChangeNotifier {
  ApiHealth._();

  static final ApiHealth instance = ApiHealth._();

  /// Espera entre uma tentativa e a seguinte, na ordem.
  ///
  /// Começa curto porque a maioria das quedas é um soluço de rede de dois
  /// segundos, e termina em 30 s porque a subida da instância leva minutos —
  /// pingar de 2 em 2 segundos durante três minutos são 90 requisições para
  /// descobrir o que uma a cada 30 s descobre igual.
  static const List<Duration> _backoff = <Duration>[
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 15),
    Duration(seconds: 30),
  ];

  /// Até quando vale a pena esperar a instância subir.
  ///
  /// Os ~190 s medidos mais folga para a primeira consulta ao banco, que também
  /// acorda fria. Depois disso o problema é outro e a resposta honesta é dizer
  /// que o servidor não respondeu, não continuar prometendo que já vai.
  static const Duration _recoveryBudget = Duration(minutes: 5);

  /// Janela em que um aquecimento novo não acrescenta nada.
  ///
  /// A instância só hiberna depois de bastante tempo ociosa; um ping bem
  /// sucedido há menos de cinco minutos já provou que ela está de pé, e repetir
  /// só gasta dado. É esta janela que faz "abriu o app" e "chegou no login"
  /// valerem por um disparo só.
  static const Duration _warmUpWindow = Duration(minutes: 5);

  /// Preguiçoso de propósito: o monitor é um singleton de campo estático, e
  /// construir um `http.Client` na criação dele significa abrir transporte antes
  /// de o app existir — o que, em teste, é abrir transporte fora da zona do
  /// teste.
  http.Client? _client;
  http.Client get _transport => _client ??= http.Client();

  bool _enabled = false;

  ApiHealthStatus _status = ApiHealthStatus.unknown;
  DateTime? _silentSince;
  DateTime? _lastAnswerAt;
  Future<bool>? _probeInFlight;
  Timer? _retryTimer;
  int _attempt = 0;

  final List<Completer<bool>> _waiters = <Completer<bool>>[];

  ApiHealthStatus get status => _status;

  /// Servidor calado e ainda dentro do tempo de subida.
  bool get isWaking => _status == ApiHealthStatus.waking;

  /// Desistimos de esperar nesta rodada.
  bool get isUnreachable => _status == ApiHealthStatus.unreachable;

  /// Há quanto tempo o servidor não responde. É este número que a faixa mostra:
  /// espera com contador é espera, espera sem contador é travamento.
  Duration get silentFor {
    final since = _silentSince;
    if (since == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(since);
  }

  /// Liga o monitor: instala o gancho de falha e passa a aceitar pings.
  ///
  /// Chamado uma vez, na abertura do app (ver `ApiWarmUpObserver`). O [client]
  /// existe para o teste trocar o transporte sem tocar na rede.
  void enable({http.Client? client}) {
    if (client != null) {
      _client = client;
    }
    if (_enabled) {
      return;
    }
    _enabled = true;
    ApiException.onFailure = _onApiFailure;
  }

  /// Dispara o aquecimento da instância, sem bloquear quem chamou.
  ///
  /// Deduplicado em três camadas, porque os gatilhos se sobrepõem de propósito
  /// (abrir o app e cair na tela de login acontecem no mesmo segundo): não pinga
  /// se já há ping em voo, se o servidor respondeu há pouco, ou se o laço de
  /// tentativas já está cuidando disso.
  void warmUp() {
    if (!_enabled || _status == ApiHealthStatus.waking) {
      return;
    }
    final last = _lastAnswerAt;
    if (last != null && DateTime.now().difference(last) < _warmUpWindow) {
      return;
    }
    unawaited(_probe());
  }

  /// Recomeça a espera por vontade da pessoa (toque na faixa de aviso).
  ///
  /// Diferente de [warmUp] em dois pontos: pinga na hora, sem esperar o degrau
  /// do laço, e zera o tempo de espera — quem tocou está dizendo "tente de
  /// novo", e o orçamento da tentativa anterior já foi gasto.
  void retryNow() {
    if (!_enabled) {
      return;
    }
    _retryTimer?.cancel();
    _retryTimer = null;
    _silentSince = DateTime.now();
    _attempt = 0;

    if (_status != ApiHealthStatus.waking) {
      _status = ApiHealthStatus.waking;
      notifyListeners();
    }
    unawaited(_probeAndContinue());
  }

  /// Completa em `true` quando o servidor voltar a atender dentro do tempo de
  /// subida, e em `false` quando não valer mais a pena esperar.
  ///
  /// É o que permite refazer sozinha a chamada que falhou (ver `ApiService`):
  /// quem pediu o dado continua pendurado no mesmo `Future`, vendo o mesmo
  /// carregamento, enquanto a faixa explica o porquê — em vez de receber um erro
  /// que só se resolve saindo e entrando do app.
  Future<bool> waitUntilReachable() {
    if (_status == ApiHealthStatus.reachable) {
      return Future<bool>.value(true);
    }
    // Esperar só faz sentido enquanto a instância está subindo. Monitor
    // desligado, estado ainda desconhecido ou desistência declarada são todos
    // "não espere" — segurar a chamada aqui seria o carregamento eterno de novo.
    if (!_enabled || _status != ApiHealthStatus.waking) {
      return Future<bool>.value(false);
    }

    final remaining = _recoveryBudget - silentFor;
    if (remaining <= Duration.zero) {
      return Future<bool>.value(false);
    }

    final waiter = Completer<bool>();
    _waiters.add(waiter);
    return waiter.future.timeout(
      remaining,
      onTimeout: () {
        _waiters.remove(waiter);
        return false;
      },
    );
  }

  /// Gancho de [ApiException.fromError]: toda falha de chamada do app passa aqui.
  void _onApiFailure(ApiFailure failure) {
    // Recusa, 404, 5xx, JSON fora do contrato — em todos o servidor **atendeu**.
    // Só a falha de transporte significa que não tem ninguém do outro lado.
    if (failure == ApiFailure.network) {
      _enterWaking();
    } else {
      _markAnswered();
    }
  }

  void _enterWaking() {
    if (_status == ApiHealthStatus.waking) {
      return;
    }
    _status = ApiHealthStatus.waking;
    _silentSince = DateTime.now();
    _attempt = 0;
    notifyListeners();
    _scheduleProbe();
  }

  void _markAnswered() {
    _lastAnswerAt = DateTime.now();
    _retryTimer?.cancel();
    _retryTimer = null;
    _attempt = 0;
    _silentSince = null;

    final changed = _status != ApiHealthStatus.reachable;
    _status = ApiHealthStatus.reachable;

    _releaseWaiters(true);
    if (changed) {
      notifyListeners();
    }
  }

  void _giveUp() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _status = ApiHealthStatus.unreachable;
    _releaseWaiters(false);
    notifyListeners();
  }

  void _releaseWaiters(bool reachable) {
    if (_waiters.isEmpty) {
      return;
    }
    final pending = List<Completer<bool>>.from(_waiters);
    _waiters.clear();
    for (final waiter in pending) {
      if (!waiter.isCompleted) {
        waiter.complete(reachable);
      }
    }
  }

  void _scheduleProbe() {
    _retryTimer?.cancel();

    if (silentFor >= _recoveryBudget) {
      _giveUp();
      return;
    }

    final delay = _backoff[math.min(_attempt, _backoff.length - 1)];
    _attempt++;

    _retryTimer = Timer(delay, () {
      if (_status != ApiHealthStatus.waking) {
        return;
      }
      unawaited(_probeAndContinue());
    });
  }

  /// Pinga e, se ninguém atendeu, marca a próxima tentativa. É o laço inteiro.
  Future<void> _probeAndContinue() async {
    final answered = await _probe();
    if (!answered && _status == ApiHealthStatus.waking) {
      _scheduleProbe();
    }
  }

  /// Um ping por vez: os gatilhos de aquecimento se sobrepõem e dois pings
  /// simultâneos custam o dobro para responder a mesma pergunta.
  Future<bool> _probe() {
    return _probeInFlight ??= _runProbe().whenComplete(() {
      _probeInFlight = null;
    });
  }

  Future<bool> _runProbe() async {
    final url = Uri.parse('$apiBaseUrl/actuator/health');

    try {
      await _transport
          .get(url, headers: await RequestContext.headers())
          .timeout(ApiTimeouts.probe);
      // Qualquer status serve. A pergunta é "tem alguém atendendo?", e um 503 de
      // instância subindo é justamente alguém atendendo — checar `200` aqui
      // manteria o app dizendo "dormindo" para um servidor já acordado.
      _markAnswered();
      return true;
    } catch (error) {
      // Sem `ApiException.fromError`: ele avisaria o gancho, que chama de volta
      // este mesmo objeto. O ping classifica por conta própria.
      final failure = ApiException.classify(error);
      if (kDebugMode) {
        debugPrint('Ping de saúde da API: $failure');
      }
      if (failure.failure == ApiFailure.network) {
        _enterWaking();
        return false;
      }
      _markAnswered();
      return true;
    }
  }

  /// Devolve o monitor ao estado de app recém-aberto. Só para teste: em produção
  /// ele vive enquanto o processo viver.
  @visibleForTesting
  void resetForTest() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _probeInFlight = null;
    _releaseWaiters(false);
    _status = ApiHealthStatus.unknown;
    _silentSince = null;
    _lastAnswerAt = null;
    _attempt = 0;
    _enabled = false;
    _client = null;
    ApiException.onFailure = null;
  }
}
