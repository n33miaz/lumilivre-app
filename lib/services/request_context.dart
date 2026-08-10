import 'package:shared_preferences/shared_preferences.dart';

/// Prazo que cada tipo de chamada tem para responder.
///
/// Os números viviam cravados em cada serviço (`Duration(seconds: 10)` em vinte
/// lugares, 30 no upload, 5 na versão), o que escondia a pergunta que de fato
/// importa: **o prazo não existe para esperar o servidor voltar, existe para
/// desistir cedo e passar o caso a quem sabe explicar**. A API roda em instância
/// que hiberna; medimos ~190 s do primeiro pacote até a porta atender. Nenhum
/// prazo sensato cobre isso — uma requisição pendurada três minutos é
/// indistinguível de app travado —, então quem espera é o monitor de saúde
/// (`ApiHealth`), que avisa a pessoa e tenta de novo, e não a requisição.
///
/// `package:http` não separa "conectar" de "receber": o `.timeout()` de cada
/// chamada é o prazo **total** dela. Onde importa distinguir, o [probe] cobre o
/// "conectar" (o ping só existe para saber se alguém atende) e os prazos longos
/// abaixo cobrem o "receber" de corpo grande.
abstract final class ApiTimeouts {
  /// Chamada comum: uma ficha, uma página de lista, uma escrita curta.
  ///
  /// Eram 10 s. Numa rede de escola em 4G congestionado o servidor **saudável**
  /// já passava disso em resposta fria de banco, e o app dizia "sem conexão" com
  /// a conexão inteira funcionando. 15 s ainda cabe dentro do que uma pessoa
  /// tolera olhando um spinner antes de concluir que algo quebrou.
  static const Duration standard = Duration(seconds: 15);

  /// Lista que cresce com o acervo: catálogo inteiro e mural.
  ///
  /// O catálogo traz até 10 livros por gênero de uma vez e o mural traz o feed
  /// completo — os dois só ficam maiores com o tempo. Cortá-los no mesmo prazo
  /// da chamada comum transformaria "lento" em "quebrado" justamente na
  /// biblioteca com mais livros.
  static const Duration heavy = Duration(seconds: 40);

  /// Envio de arquivo (foto de perfil).
  ///
  /// Eram 30 s. Uma JPEG de câmera de celular tem 3–4 MB e a subida de 3G de
  /// escola anda a ~100 kB/s: o envio honesto passa de meio minuto e os 30 s
  /// cortavam quase no fim, depois de a pessoa já ter esperado. Aqui o prazo
  /// precisa caber o upload, não medir o servidor.
  static const Duration upload = Duration(seconds: 90);

  /// Ping de saúde/aquecimento (`/actuator/health`).
  ///
  /// Não entrega dado nenhum: só responde "tem alguém aí?". Curto de propósito,
  /// porque ele roda em laço com espera crescente — prazo longo aqui só atrasa a
  /// próxima tentativa.
  static const Duration probe = Duration(seconds: 8);

  /// Gate de versão na abertura do app.
  ///
  /// Continua curto (e o provider falha aberto): ele atrasa a primeira tela, e
  /// servidor dormindo não pode virar splash infinito.
  static const Duration versionGate = Duration(seconds: 5);
}

class RequestContext {
  static const _localeKey = 'app_locale';

  static Future<String> currentLocaleTag() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'pt-BR';
  }

  static Future<Map<String, String>> headers({String? token}) async {
    final headers = <String, String>{
      'Accept-Language': await currentLocaleTag(),
      // Identifica o canal para a auditoria de acessos da API.
      'X-Client': 'APP',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Map<String, String>> jsonHeaders({String? token}) async {
    final requestHeaders = await headers(token: token);
    requestHeaders['Content-Type'] = 'application/json; charset=UTF-8';
    return requestHeaders;
  }
}
