# LumiLivre App - Project Context

## Objetivo

`lumilivre-app` e o aplicativo Flutter voltado aos alunos. Ele funciona como vitrine digital do acervo, consulta detalhes e disponibilidade, permite solicitacao de emprestimo, exibe emprestimos/historico, favoritos, ranking e dados de perfil. Tambem existe modo convidado para navegacao limitada.

## Stack Tecnologica

- Linguagem: Dart.
- Framework: Flutter.
- SDK Dart: `^3.9.2`.
- Estado: Provider 6.1 com `ChangeNotifier`.
- HTTP: `http` 1.5.
- Persistencia local: `shared_preferences`.
- UI/assets: Material, `flutter_svg`, `cached_network_image`, assets locais.
- Internacionalizacao/formatacao: `intl`.
- Links externos: `url_launcher`.
- Seguranca local: `local_auth` para preferencia de biometria.
- Upload/imagem: `image_picker`, `http_parser`.
- Conectividade: `connectivity_plus`, `internet_connection_checker`.
- Testes: `flutter_test`, `flutter_lints`.
- Geracao visual: `flutter_launcher_icons`, `flutter_native_splash`.

## Arquitetura Observada

O app usa uma arquitetura Flutter pragmatica orientada a telas:

- `main.dart`: bootstrap, tratamento global de erros e registro dos providers.
- `providers`: estado transversal de autenticacao, tema e favoritos.
- `services`: comunicacao REST e regra pura auxiliar.
- `models`: parse e normalizacao dos contratos recebidos da API.
- `screens`: telas e navegacao.
- `widgets`: componentes reutilizaveis.
- `utils`: constantes, tema e parsers.
- `test`: testes de providers, modelos, servicos e regras de status.

O padrao e proximo de MVVM/Provider, com `ChangeNotifier` como view model simples e `ApiService` como service/facade de dados. Nao ha separacao formal por Clean Architecture, mas a regra critica de status de emprestimo foi extraida para `LoanStatusCalculator`, o que melhora testabilidade e coesao.

## Modulos Principais

- Autenticacao:
  - Login por matricula ou email.
  - Modo convidado.
  - Persistencia de token e usuario em `SharedPreferences`.
  - Sinalizacao de senha inicial obrigatoria.
- Catalogo:
  - Busca catalogo agrupado por genero em `/livros/catalogo-mobile`.
  - Cache local `catalog_cache_v1`.
  - Stale-while-revalidate: mostra cache local e atualiza remoto em segundo plano.
  - Paginacao visual por categorias.
- Busca e categorias:
  - Busca por texto em `/livros/mobile/buscar`.
  - Navegacao por categorias fixas e endpoint `/livros/genero/{nomeGenero}`.
- Detalhes do livro:
  - Consulta `/livros/{id}`.
  - Calcula status local de emprestimo.
  - Envia solicitacao por livro em `/solicitacoes/solicitar-mobile`.
- Perfil:
  - Dados do aluno em `/alunos/{matricula}`.
  - Upload de foto em `/alunos/{matricula}/foto`.
  - Tabs de emprestimos, favoritos e ranking.
- Emprestimos:
  - Ativos em `/emprestimos/aluno/{matricula}`.
  - Historico em `/emprestimos/aluno/{matricula}/historico`.
  - Solicitacoes em `/solicitacoes/aluno/{matricula}`.
- Ranking:
  - `/emprestimos/ranking` com filtros de curso, modulo e turno.
  - Listas auxiliares: `/cursos/home`, `/modulos`, `/turnos`.
- Configuracoes:
  - Tema claro/escuro/sistema.
  - Alteracao de senha.
  - Logout.
  - Preferencia de biometria salva localmente.

## Autenticacao e Comunicacao

- `ApiService` e singleton.
- `AuthProvider.login` chama `ApiService.login`.
- Token JWT fica em `SharedPreferences` com chave `authToken`.
- Dados do usuario ficam em `SharedPreferences` com chave `userData`.
- Chamadas sensiveis enviam `Authorization: Bearer <token>`.
- `LoginResponse` espera `id`, `email`, `role`, `matriculaAluno`, `token` e `isInitialPassword`.
- `isInitialPassword=true` bloqueia o navegador principal ate o usuario trocar senha.
- Troca de senha usa `PUT /usuarios/alterar-senha`.
- Modo convidado nao autentica token e deve bloquear a solicitacao de emprestimo.
- O app possui `tryAutoLogin`, mas o bootstrap atual nao o chama em `main.dart`. Se a sessao deve sobreviver a reinicializacao, esse fluxo precisa ser invocado antes de decidir a `home`.

## Regras de Negocio no App

`LoanStatusCalculator` define a regra de apresentacao do botao de emprestimo:

1. Emprestimo ativo do mesmo livro tem prioridade e vira `active` ou `overdue`.
2. Solicitacao pendente do mesmo livro vira `pending`.
3. Livro sem exemplares cadastrados vira `noCopies`.
4. Aluno com penalidade vira `blockedPenalty`.
5. Aluno com 3 ou mais emprestimos vira `limitReached`.
6. Livro sem exemplares disponiveis vira `unavailable`.
7. Caso contrario, vira `available`.

Outras regras locais:

- Convidado pode navegar, mas nao solicitar emprestimo nem ver dados pessoais.
- Favoritos sao locais por ID do livro.
- Tema e persistido localmente.
- Catalogo local e usado quando a rede falha.
- Imagens HTTP sao normalizadas para HTTPS em alguns parsers.
- Alteracao de senha exige senha atual, nova senha com minimo de 6 caracteres e confirmacao.

## Integracoes Externas

- LumiLivre API REST.
- `SharedPreferences` para cache e sessao local.
- `ImagePicker` para foto de perfil.
- `Connectivity` para banner offline.
- `url_launcher` abre fluxo web de "esqueci minha senha".
- `local_auth` verifica suporte e salva preferencia de biometria, mas o fluxo completo de login biometrico nao aparece implementado no codigo analisado.

## Estrutura de Pastas

```text
lib/
  main.dart
  models/
  providers/
  screens/
    auth/
  services/
  utils/
  widgets/
assets/
  animations/
  icons/
  images/
test/
  helpers/
  models/
  providers/
  screens/
  services/
  utils/
android/
ios/
web/
```

## Comandos Essenciais

```powershell
# instalar dependencias
flutter pub get

# executar localmente
flutter run

# executar testes
flutter test

# analisar lint
flutter analyze

# build Android
flutter build apk

# build Web
flutter build web

# build iOS em ambiente macOS
flutter build ios
```

## Configuracao de API

A URL da API esta hardcoded em `lib/utils/constants.dart`:

```dart
const String apiBaseUrl = 'http://127.0.0.1:8080';
```

Para producao, trocar para a URL publica da API antes do build ou evoluir para configuracao por flavor/env.

## Qualidade, Escalabilidade e Pontos de Atencao

- A extracao de `LoanStatusCalculator` e um bom exemplo de regra pura testavel.
- O app possui testes relevantes para modelos, providers, parsers, status de emprestimo e cache.
- `ApiService` concentra muitas responsabilidades. Em crescimento, dividir por dominio (`AuthApi`, `CatalogApi`, `LoanApi`, `StudentApi`) reduzira acoplamento.
- Sessao local precisa chamar `tryAutoLogin` no startup se persistencia entre aberturas for requisito.
- Biometria hoje parece uma preferencia local, nao um fluxo de autenticacao completo.
- A URL de API hardcoded dificulta builds por ambiente.
- Para seguranca mobile, considerar armazenamento seguro para token em vez de `SharedPreferences`, especialmente fora de prototipo/TCC.
